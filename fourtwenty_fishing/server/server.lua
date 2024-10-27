--[[
    server.lua
    Part of FourTwenty Fishing System
    https://fourtwenty.dev | https://github.com/FourTwentyDev
    
    Main server-side functionality including database management,
    fishing mechanics, and player progression
    Version: 1.0.0
]]

ESX = exports["es_extended"]:getSharedObject()

-- Database initialization
MySQL.ready(function()
    MySQL.Async.execute([[ 
        CREATE TABLE IF NOT EXISTS fourtwenty_fishing (
            identifier VARCHAR(50) PRIMARY KEY,
            level INT DEFAULT 1,
            xp INT DEFAULT 0
        )
    ]])
    
    MySQL.Async.execute([[
        CREATE TABLE IF NOT EXISTS fourtwenty_fishing_catches (
            identifier VARCHAR(50),
            fish_name VARCHAR(50),
            fish_count INT DEFAULT 0,
            PRIMARY KEY (identifier, fish_name)
        )
    ]])
end)

-- Utility Functions
---Calculate player level based on XP
---@param xp number The player's current XP
---@return number The calculated level
local function CalculateLevel(xp)
    return math.floor(math.sqrt(xp / 100)) + 1
end

---Get a random fish using weighted probability based on rarity
---@return table The selected fish configuration
local function GetRandomFish()
    local totalWeight = 0
    local weights = {}
    
    -- Calculate weights based on rarity
    for _, fish in pairs(Config.Fish) do
        local weight = 1 / fish.rarity
        totalWeight = totalWeight + weight
        table.insert(weights, {fish = fish, weight = totalWeight})
    end
    
    -- Select random fish based on weight
    local random = math.random() * totalWeight
    for _, entry in pairs(weights) do
        if random <= entry.weight then
            return entry.fish
        end
    end
    
    return Config.Fish[1] -- Fallback to first fish
end

-- Database Operations
---Add fishing XP and handle level ups
---@param identifier string Player identifier
---@param xp number Amount of XP to add
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
            
            -- Handle level up
            if newLevel > result[1].level then
                local xPlayer = ESX.GetPlayerFromIdentifier(identifier)
                if xPlayer then
                    TriggerClientEvent('fishing:levelUp', xPlayer.source, newLevel)
                end
            end
        end
    end)
end

---Track fish catches in database
---@param identifier string Player identifier
---@param fish_name string Name of the caught fish
local function TrackFishCatch(identifier, fish_name)
    MySQL.Async.fetchAll('SELECT * FROM fourtwenty_fishing_catches WHERE identifier = @identifier AND fish_name = @fish_name', {
        ['@identifier'] = identifier,
        ['@fish_name'] = fish_name
    }, function(result)
        if result[1] then
            local newFishCount = result[1].fish_count + 1
            MySQL.Async.execute('UPDATE fourtwenty_fishing_catches SET fish_count = @fish_count WHERE identifier = @identifier AND fish_name = @fish_name', {
                ['@identifier'] = identifier,
                ['@fish_name'] = fish_name,
                ['@fish_count'] = newFishCount
            })
        else
            MySQL.Async.execute('INSERT INTO fourtwenty_fishing_catches (identifier, fish_name, fish_count) VALUES (@identifier, @fish_name, 1)', {
                ['@identifier'] = identifier,
                ['@fish_name'] = fish_name
            })
        end
    end)
end

-- Callbacks and Events
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

RegisterServerEvent('fishing:attemptCatch')
AddEventHandler('fishing:attemptCatch', function(rodType)
    local xPlayer = ESX.GetPlayerFromId(source)
    local rod = nil
    
    -- Find the fishing rod configuration
    for _, fishingRod in pairs(Config.FishingRods) do
        if fishingRod.item == rodType then
            rod = fishingRod
            break
        end
    end
    
    if not rod then return end
    
    -- Attempt catch based on rod's catch chance
    if math.random() <= rod.catchChance then
        local fish = GetRandomFish()
        xPlayer.addInventoryItem(fish.item, 1)
        AddFishingXP(xPlayer.identifier, fish.xp * rod.xpMultiplier)
        TrackFishCatch(xPlayer.identifier, fish.name)
        TriggerClientEvent('fishing:catchSuccess', source, fish)
    else
        TriggerClientEvent('fishing:catchFailed', source)
    end
end)

ESX.RegisterServerCallback('fishing:getRodCount', function(source, cb, rodItem)
    local xPlayer = ESX.GetPlayerFromId(source)
    local itemCount = xPlayer.getInventoryItem(rodItem).count
    cb(itemCount)
end)

-- Commands
RegisterCommand('fishingstats', function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    MySQL.Async.fetchAll('SELECT * FROM fourtwenty_fishing WHERE identifier = @identifier', {
        ['@identifier'] = xPlayer.identifier
    }, function(result)
        if result[1] then
            local level = result[1].level
            local xp = result[1].xp
            
            MySQL.Async.fetchAll('SELECT * FROM fourtwenty_fishing_catches WHERE identifier = @identifier', {
                ['@identifier'] = xPlayer.identifier
            }, function(catches)
                local achievements = {}
                local totalFishCaught = 0
                
                -- Compile catch statistics
                for _, catch in pairs(catches) do
                    table.insert(achievements, string.format("%s: %d", catch.fish_name, catch.fish_count))
                    totalFishCaught = totalFishCaught + catch.fish_count
                end

                -- Display stats in chat
                TriggerClientEvent('chat:addMessage', source, {
                    args = { 
                        'FourTwenty Fishing Stats', 
                        string.format('Level: %d, XP: %d, Total Fish: %d', level, xp, totalFishCaught)
                    }
                })
                
                -- Display individual achievements
                for _, achievement in pairs(achievements) do
                    TriggerClientEvent('chat:addMessage', source, {
                        args = { 'Fishing Achievements', achievement }
                    })
                end
            end)
        else
            TriggerClientEvent('chat:addMessage', source, {
                args = { 'Fishing Stats', 'No fishing data found.' }
            })
        end
    end)
end, false)