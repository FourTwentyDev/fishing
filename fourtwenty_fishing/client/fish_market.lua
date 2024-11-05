--[[
    fish_market.lua
    Part of FourTwenty Fishing System
    https://fourtwenty.dev | https://github.com/FourTwentyDev
    
    Handles all fish market related functionality including UI and selling mechanics
    Version: 1.0.0
]]

ESX = exports["es_extended"]:getSharedObject()

-- Local state variables
local showMarketUI = false
local currentPrices = {}
local nextUpdate = 0
local lastUpdateTime = 0

-- Get UI translations
function GetUITranslations()
    local translations = {}
    local keys = {
        'ui_fish_market',
        'ui_next_price_change',
        'ui_total_value',
        'ui_sell_all',
        'ui_price',
        'ui_quantity',
        'ui_base_price',
        'ui_current_price',
        'ui_trend_up',
        'ui_trend_down',
        'ui_trend_stable',
        'ui_close'
    }
    
    for _, key in ipairs(keys) do
        translations[key] = translate(key)
    end
    
    return translations
end

-- Market UI Functions
function OpenFishMarket()
    if showMarketUI then return end
    
    showMarketUI = true
    SetNuiFocus(true, true)
    
    -- Send initial data
    SendNUIMessage({
        type = 'showUI',
        translations = GetUITranslations(),
        locale = Config.Locale or 'de'
    })
    
    TriggerServerEvent('fishing:requestMarketData')
end

function CloseFishMarket()
    if not showMarketUI then return end
    
    showMarketUI = false
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = 'hideUI'
    })
end

function UpdateFishMarketUI()
    if not showMarketUI then return end
    
    local inventory = {}
    local totalValue = 0
    local playerInventory = {}
    local currentTime = GetGameTimer()
    local timeUntilUpdate = math.max(0, nextUpdate - (currentTime - lastUpdateTime))

    if Config.ox_inventory then
        playerInventory = exports.ox_inventory:Items()
    else
        playerInventory = ESX.GetPlayerData().inventory
    end
    
    for _, fish in pairs(Config.Fish) do
        local inventoryItem = nil
        local itemCount = 0
        
        -- Get item count from inventory
        if type(playerInventory) == "table" then
            if playerInventory[fish.item] then
                inventoryItem = playerInventory[fish.item]
                if type(inventoryItem) == "table" then
                    itemCount = tonumber(inventoryItem.count) or tonumber(inventoryItem.amount) or 0
                end
            else
                for _, item in ipairs(playerInventory) do
                    if item.name == fish.item and type(item) == "table" then
                        inventoryItem = item
                        itemCount = tonumber(item.count) or tonumber(item.amount) or 0
                        break
                    end
                end
            end
        end

        -- Only add fish with count > 0
        if itemCount > 0 then
            local currentPrice = currentPrices[fish.item] or fish.price
            local trend = "none"

            if currentPrice and fish.price then
                trend = (currentPrice > fish.price) and "up" or 
                       (currentPrice < fish.price) and "down" or "none"
            end

            table.insert(inventory, {
                name = fish.name,
                count = itemCount,
                basePrice = fish.price,
                currentPrice = currentPrice,
                trend = trend,
                item = fish.item
            })
            
            totalValue = totalValue + (currentPrice * itemCount)
        end
    end
    
    SendNUIMessage({
        type = "updateFishMarketUI",
        inventory = inventory,
        totalValue = totalValue,
        nextUpdate = timeUntilUpdate,
        dynamicPricing = Config.DynamicPricing.enabled
    })
end

-- NUI Callbacks
RegisterNUICallback('closeUI', function(data, cb)
    CloseFishMarket()
    cb('ok')
end)

RegisterNUICallback('sellFish', function(data, cb)
    if not data then 
        cb('error')
        return
    end
    
    TriggerServerEvent('fishing:sellFish')
    Wait(500) -- Small delay to ensure server processed the sale
    UpdateFishMarketUI()
    cb('ok')
end)

RegisterNUICallback('getTranslations', function(data, cb)
    cb({
        translations = GetUITranslations(),
        locale = Config.Locale or 'de'
    })
end)

-- Server Events
RegisterNetEvent('fishing:openMarketUI')
AddEventHandler('fishing:openMarketUI', function(prices, updateTime)
    currentPrices = prices
    nextUpdate = updateTime
    lastUpdateTime = GetGameTimer()
    UpdateFishMarketUI()
end)

RegisterNetEvent('fishing:sellComplete')
AddEventHandler('fishing:sellComplete', function(earnings)
    if earnings and earnings > 0 then
        ESX.ShowNotification(translate('fish_sold', earnings))
    end
    if showMarketUI then
        UpdateFishMarketUI()
    end
end)

RegisterNetEvent('fishing:updatePrices')
AddEventHandler('fishing:updatePrices', function(newPrices, timeUntilNext)
    currentPrices = newPrices
    nextUpdate = timeUntilNext
    lastUpdateTime = GetGameTimer()
    if showMarketUI then
        UpdateFishMarketUI()
    end
end)

-- Market interaction thread
CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)
        local distance = #(coords - Config.SellPoint.coords)

        if distance < 3.0 then
            sleep = 0
            if not showMarketUI then
                ESX.ShowHelpNotification(translate('press_sell_fish'))
                
                if IsControlJustPressed(0, 38) then -- E key
                    OpenFishMarket()
                end
            end
        elseif showMarketUI then
            CloseFishMarket()
        end

        Wait(sleep)
    end
end)

-- UI update timer
CreateThread(function()
    while true do
        if showMarketUI then
            UpdateFishMarketUI()
        end
        Wait(1000)
    end
end)
