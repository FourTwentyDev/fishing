--[[
    fish_market.lua
    Part of FourTwenty Fishing System
    https://fourtwenty.dev | https://github.com/FourTwentyDev
    
    Handles all server-side market functionality including price calculations
    and selling mechanics
    Version: 1.0.0
]]

ESX = exports["es_extended"]:getSharedObject()

-- Local state variables
local currentPrices = {}
local nextUpdateTime = 0

-- Initialize market prices for all fish
local function InitializePrices()
    for _, fish in pairs(Config.Fish) do
        currentPrices[fish.item] = fish.price
    end
    nextUpdateTime = os.time() + math.floor(Config.DynamicPricing.updateInterval / 1000)
end

-- Calculate new dynamic price based on configuration
---@param basePrice number The base price of the fish
---@param currentPrice number The current market price
---@return number The newly calculated price
local function CalculateNewPrice(basePrice, currentPrice)
    -- Convert percentages to whole numbers (work with cents instead of euros)
    local maxChangePercent = Config.DynamicPricing.maxPriceChangePercent
    local maxChange = math.floor(basePrice * maxChangePercent / 100)
    local minPrice = math.floor(basePrice * Config.DynamicPricing.priceFluctuation.min)
    local maxPrice = math.floor(basePrice * Config.DynamicPricing.priceFluctuation.max)
    
    -- math.random requires whole numbers
    local change = math.random(-maxChange, maxChange)
    local newPrice = math.floor(currentPrice + change)
    
    -- Ensure price stays within configured bounds
    return math.max(minPrice, math.min(maxPrice, newPrice))
end

-- Update all fish prices and broadcast to clients
local function UpdatePrices()
    if not Config.DynamicPricing.enabled then return end
    
    -- Update prices
    local pricesChanged = false
    for _, fish in pairs(Config.Fish) do
        local newPrice = CalculateNewPrice(fish.price, currentPrices[fish.item])
        if newPrice ~= currentPrices[fish.item] then
            currentPrices[fish.item] = newPrice
            pricesChanged = true
        end
    end
    
    -- Update next update timestamp
    nextUpdateTime = os.time() + math.floor(Config.DynamicPricing.updateInterval / 1000)
    
    -- Broadcast new prices if any changed
    if pricesChanged then
        local timeUntilUpdate = math.floor(Config.DynamicPricing.updateInterval)
        TriggerClientEvent('fishing:updatePrices', -1, currentPrices, timeUntilUpdate)
        print("[FourTwenty Fishing] Market prices updated")

        -- Debug price logging
        for item, price in pairs(currentPrices) do
            print(string.format("[FourTwenty Fishing] New price for %s: $%d", item, price))
        end
    end
end

-- Price update thread
CreateThread(function()
    InitializePrices()
    print("[FourTwenty Fishing] Market system initialized")
    
    while true do
        local currentTime = os.time()
        if Config.DynamicPricing.enabled and currentTime >= nextUpdateTime then
            UpdatePrices()
        end
        Wait(5000) -- Check every 5 seconds
    end
end)

-- Handle sell request from client
RegisterServerEvent('fishing:sellFish')
AddEventHandler('fishing:sellFish', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then 
        print("[FourTwenty Fishing] Error: Player not found")
        return 
    end
    
    local totalEarnings = 0
    local soldItems = {}
    
    -- First check inventory and calculate totals
    for _, fish in pairs(Config.Fish) do
        local fishItem = xPlayer.getInventoryItem(fish.item)
        
        if fishItem and fishItem.count and fishItem.count > 0 then
            local price = currentPrices[fish.item] or fish.price
            local earnings = math.floor(fishItem.count * price)
            
            table.insert(soldItems, {
                item = fish.item,
                count = fishItem.count,
                price = price,
                earnings = earnings
            })
            
            totalEarnings = totalEarnings + earnings
        end
    end
    
    -- Then process the transaction if there's anything to sell
    if totalEarnings > 0 then
        -- Debug output
        print(string.format("[FourTwenty Fishing] Starting sale for player %s", xPlayer.identifier))
        print(string.format("[FourTwenty Fishing] Total earnings calculated: $%d", totalEarnings))
        
        -- Add money first
        xPlayer.addAccountMoney('money', totalEarnings)
        
        -- Then remove items
        for _, sale in ipairs(soldItems) do
            xPlayer.removeInventoryItem(sale.item, sale.count)
            print(string.format("[FourTwenty Fishing] Sold %dx %s for $%d each", 
                sale.count, sale.item, sale.price))
        end
        
        -- Notify client of successful sale
        TriggerClientEvent('fishing:sellComplete', source, totalEarnings)
        print(string.format("[FourTwenty Fishing] Sale completed for %s: $%d", 
            xPlayer.identifier, totalEarnings))
    else
        print(string.format("[FourTwenty Fishing] No items to sell for player %s", xPlayer.identifier))
    end
end)

-- Send market data to client
RegisterServerEvent('fishing:requestMarketData')
AddEventHandler('fishing:requestMarketData', function()
    -- Calculate remaining time in milliseconds
    local timeUntilUpdate = math.max(0, nextUpdateTime - os.time()) * 1000
    TriggerClientEvent('fishing:openMarketUI', source, currentPrices, timeUntilUpdate)
end)