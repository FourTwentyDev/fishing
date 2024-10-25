ESX = exports["es_extended"]:getSharedObject()

-- Database initialization
MySQL.ready(function()
    -- Table for fishing experience
    MySQL.Async.execute([[ 
        CREATE TABLE IF NOT EXISTS fourtwenty_fishing (
            identifier VARCHAR(50) PRIMARY KEY,
            level INT DEFAULT 1,
            xp INT DEFAULT 0
        )
    ]])
    
    -- Table for tracking fish catches
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS fourtwenty_fishing_catches (
            identifier VARCHAR(50),
            fish_name VARCHAR(50),
            fish_count INT DEFAULT 0,
            PRIMARY KEY (identifier, fish_name)
        )
    ]])
end)

-- Helper function to calculate level from XP
local function CalculateLevel(xp)
    return math.floor(math.sqrt(xp / 100)) + 1
end

-- Helper function to get random fish based on rarity
local function GetRandomFish()
    local totalWeight = 0
    local weights = {}
    
    for _, fish in pairs(Config.Fish) do
        local weight = 1 / fish.rarity
        totalWeight = totalWeight + weight
        table.insert(weights, {fish = fish, weight = totalWeight})
    end
    
    local random = math.random() * totalWeight
    for _, entry in pairs(weights) do
        if random <= entry.weight then
            return entry.fish
        end
    end
    
    return Config.Fish[1] -- Fallback to first fish
end

-- Helper function to add XP and handle level ups
local function AddFishingXP(identifier, xp)
    MySQL.Async.fetchAll('SELECT * FROM fourtwenty_fishing WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(result)
        if result[1] then
            local currentXP = result[1].xp + xp
            local newLevel = CalculateLevel(currentXP)
            
            MySQL.Async.execute('UPDATE fourtwenty_fishing SET xp = @xp, level = @level WHERE identifier = @identifier', {
                ['@identifier'] = identifier,
                ['@xp'] = currentXP,
                ['@level'] = newLevel
            })
            
            if newLevel > result[1].level then
                local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
                if xPlayer then
                    TriggerClientEvent('fishing:levelUp', xPlayer.source, newLevel)
                end
            end
        end
    end)
end

-- Helper function to track fish catches
local function TrackFishCatch(identifier, fish_name)
    MySQL.Async.fetchAll('SELECT * FROM fourtwenty_fishing_catches WHERE identifier = @identifier AND fish_name = @fish_name', {
        ['@identifier'] = identifier,
        ['@fish_name'] = fish_name
    }, function(result)
        if result[1] then
            -- If fish already exists in the table, increment count
            local newFishCount = result[1].fish_count + 1
            MySQL.Async.execute('UPDATE fourtwenty_fishing_catches SET fish_count = @fish_count WHERE identifier = @identifier AND fish_name = @fish_name', {
                ['@identifier'] = identifier,
                ['@fish_name'] = fish_name,
                ['@fish_count'] = newFishCount
            })
        else
            -- Insert new fish catch record
            MySQL.Async.execute('INSERT INTO fourtwenty_fishing_catches (identifier, fish_name, fish_count) VALUES (@identifier, @fish_name, 1)', {
                ['@identifier'] = identifier,
                ['@fish_name'] = fish_name
            })
        end
    end)
end

-- Get player fishing data
ESX.RegisterServerCallback('fishing:getPlayerData', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchAll('SELECT * FROM fourtwenty_fishing WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            cb(result[1])
        else
            MySQL.Async.execute('INSERT INTO fourtwenty_fishing (identifier) VALUES (@identifier)', {
                ['@identifier'] = xPlayer.identifier
            })
            cb({level = 1, xp = 0})
        end
    end)
end)

-- Handle fishing attempt
RegisterServerEvent('fishing:attemptCatch')
AddEventHandler('fishing:attemptCatch', function(rodType)
    local xPlayer = ESX.GetPlayerFromId(source)
    local rod = nil
    
    for _, fishingRod in pairs(Config.FishingRods) do
        if fishingRod.item == rodType then
            rod = fishingRod
            break
        end
    end
    
    if not rod then return end
    
    if math.random() <= rod.catchChance then
        local fish = GetRandomFish()
        xPlayer.addInventoryItem(fish.item, 1)
        AddFishingXP(xPlayer.identifier, fish.xp * rod.xpMultiplier)
        TrackFishCatch(xPlayer.identifier, fish.name)  -- Track fish catch
        TriggerClientEvent('fishing:catchSuccess', source, fish)
    else
        TriggerClientEvent('fishing:catchFailed', source)
    end
end)

-- Handle fish selling
RegisterServerEvent('fishing:sellFish')
AddEventHandler('fishing:sellFish', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    local totalEarnings = 0
    
    for _, fish in pairs(Config.Fish) do
        local fishCount = xPlayer.getInventoryItem(fish.item).count
        if fishCount > 0 then
            local earnings = fishCount * fish.price
            xPlayer.removeInventoryItem(fish.item, fishCount)
            xPlayer.addMoney(earnings)
            totalEarnings = totalEarnings + earnings
        end
    end
    
    if totalEarnings > 0 then
        TriggerClientEvent('fishing:sellComplete', source, totalEarnings)
    end
end)

ESX.RegisterServerCallback('fishing:getRodCount', function(source, cb, rodItem)
    local xPlayer = ESX.GetPlayerFromId(source)
    local itemCount = xPlayer.getInventoryItem(rodItem).count
    cb(itemCount)
end)

-- Server-side command to display fishing level and achievements
RegisterCommand('fishingstats', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    -- Fetch player's fishing data (level and XP)
    MySQL.Async.fetchAll('SELECT * FROM fourtwenty_fishing WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            local level = result[1].level
            local xp = result[1].xp
            
            -- Fetch player's fishing achievements (how many fish caught)
            MySQL.Async.fetchAll('SELECT * FROM fourtwenty_fishing_catches WHERE identifier = @identifier', {
                ['@identifier'] = xPlayer.identifier
            }, function(catches)
                local achievements = {}
                local totalFishCaught = 0
                
                for _, catch in pairs(catches) do
                    table.insert(achievements, string.format("%s: %d", catch.fish_name, catch.fish_count))
                    totalFishCaught = totalFishCaught + catch.fish_count
                end

                -- Sending the data back to the player via chat
                TriggerClientEvent('chat:addMessage', source, {
                    args = { 
                        'Fishing Stats', 
                        string.format('Level: %d, XP: %d, Total Fish Caught: %d', level, xp, totalFishCaught)
                    }
                })
                
                -- Display individual achievements (which fish and how many)
                for _, achievement in pairs(achievements) do
                    TriggerClientEvent('chat:addMessage', source, {
                        args = { 'Achievements', achievement }
                    })
                end
            end)
        else
            -- In case no data is found for the player
            TriggerClientEvent('chat:addMessage', source, {
                args = { 'Fishing Stats', 'No fishing data found for you.' }
            })
        end
    end)
end, false) -- false = no admin permissions required
