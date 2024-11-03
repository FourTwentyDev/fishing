--[[
    client.lua
    Part of FourTwenty Fishing System
    https://fourtwenty.dev | https://github.com/FourTwentyDev
    
    Main client-side functionality for fishing mechanics
    Version: 1.0.0
]]

ESX = exports["es_extended"]:getSharedObject()

-- Local variables
local isFishing = false
local currentZone = nil
local showHelpText = false
local fishingData = {level = 1, xp = 0}
local lastFishingPos = nil

-- Animation constants
local ANIMS = {
    WAITING = "amb@world_human_stand_fishing@idle_a",
    WAITING_ACTION = "idle_c",
    SUCCESS = "anim@mp_player_intcelebrationmale@thumbs_up",
    SUCCESS_ACTION = "thumbs_up",
    FAIL = "anim@mp_player_intcelebrationmale@face_palm",
    FAIL_ACTION = "face_palm"
}

-- Function to load animation dictionaries
function LoadFishingAnimations()
    CreateThread(function()
        for dict, _ in pairs(ANIMS) do
            RequestAnimDict(dict)
            local attempts = 0
            
            while not HasAnimDictLoaded(dict) and attempts < 10 do
                Wait(100)
                attempts = attempts + 1
            end
            
            if attempts >= 10 then
                print('Failed to load animation dictionary: ' .. dict)
            end
        end
    end)
end

-- Function to get initial player fishing data
function InitializeFishingData()
    CreateThread(function()
        ESX.TriggerServerCallback('fishing:getPlayerData', function(data)
            fishingData = data
        end)
    end)
end

-- Call both functions to maintain original functionality
CreateThread(function()
    InitializeFishingData()
    LoadFishingAnimations()
end)

-- Main loop for zone checks and interactions
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local wait = 1000
        
        -- Check player status
        if not IsEntityDead(playerPed) and not IsPedInAnyVehicle(playerPed, false) and not IsPedSwimming(playerPed) then
            -- Check fishing zones
            for _, zone in pairs(Config.FishingZones) do
                local distance = #(playerCoords - zone.coords)
                if distance <= zone.radius then
                    currentZone = zone
                    wait = 0
                    
                    if not isFishing then
                        -- Show appropriate help texts
                        if not showHelpText then
                            if Config.FishingSettings.autoFishing then
                                ESX.ShowHelpNotification(translate('press_start_auto_fishing'))
                            else
                                ESX.ShowHelpNotification(translate('press_start_fishing'))
                            end
                            showHelpText = true
                        end
                        
                        -- Start fishing on key press
                        if IsControlJustPressed(0, Config.FishingSettings.startKey) then
                            StartFishing()
                        end
                    elseif IsControlJustPressed(0, Config.FishingSettings.cancelKey) then
                        StopFishing()
                    end
                    break
                else
                    showHelpText = false
                end
            end
        end

        -- Reset zone if too far away
        if wait == 1000 then
            currentZone = nil
            showHelpText = false
        end
        
        Wait(wait)
    end
end)

-- Blips and NPC Setup
CreateThread(function()
    -- Create fish market blip
    local marketBlip = AddBlipForCoord(Config.SellPoint.coords)
    SetBlipSprite(marketBlip, Config.Blips.FishMarket.sprite)
    SetBlipDisplay(marketBlip, Config.Blips.FishMarket.display)
    SetBlipScale(marketBlip, Config.Blips.FishMarket.scale)
    SetBlipColour(marketBlip, Config.Blips.FishMarket.color)
    SetBlipAsShortRange(marketBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(translate('blip_fish_market'))
    EndTextCommandSetBlipName(marketBlip)
    
    -- Create fishing zone blips
    for _, zone in pairs(Config.FishingZones) do
        -- Radius blip
        local radiusBlip = AddBlipForRadius(zone.coords, zone.radius)
        SetBlipRotation(radiusBlip, 0)
        SetBlipColour(radiusBlip, zone.blipColor)
        SetBlipAlpha(radiusBlip, zone.blipAlpha)
        
        -- Center blip
        local centerBlip = AddBlipForCoord(zone.coords)
        SetBlipSprite(centerBlip, Config.Blips.FishingSpot.sprite)
        SetBlipDisplay(centerBlip, Config.Blips.FishingSpot.display)
        SetBlipScale(centerBlip, Config.Blips.FishingSpot.scale)
        SetBlipColour(centerBlip, Config.Blips.FishingSpot.color)
        SetBlipAsShortRange(centerBlip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(zone.name)
        EndTextCommandSetBlipName(centerBlip)
    end
    
    -- Create seller NPC
    RequestModel(GetHashKey(Config.SellPoint.npcModel))
    while not HasModelLoaded(GetHashKey(Config.SellPoint.npcModel)) do
        Wait(1)
    end
    
    local npc = CreatePed(4, GetHashKey(Config.SellPoint.npcModel), 
        Config.SellPoint.coords.x, Config.SellPoint.coords.y, Config.SellPoint.coords.z - 1.0, 
        Config.SellPoint.heading or 0.0, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
end)

-- Function to find the best available fishing rod
function GetFishingRod(cb)
    local sortedFishingRods = {}
    for i = 1, #Config.FishingRods do
        sortedFishingRods[i] = Config.FishingRods[i]
    end

    -- Sort by required level (highest first)
    table.sort(sortedFishingRods, function(a, b)
        return a.requiredLevel > b.requiredLevel
    end)

    local bestRod = nil
    local canUseRod = false
    local rodCount = 0

    for _, fishingRod in pairs(sortedFishingRods) do
        ESX.TriggerServerCallback('fishing:getRodCount', function(count)
            rodCount = rodCount + 1

            if count > 0 then
                if fishingData.level >= (fishingRod.requiredLevel or 1) then
                    bestRod = fishingRod
                    canUseRod = true
                    cb(bestRod)
                    return
                else
                    bestRod = fishingRod
                end
            end

            if rodCount == #sortedFishingRods and not canUseRod then
                if bestRod then
                    ESX.ShowNotification(translate('level_too_low', bestRod.requiredLevel))
                else
                    ESX.ShowNotification(translate('need_rod'))
                end
                cb(nil)
            end
        end, fishingRod.item)
    end
end

-- Main function to start fishing
function StartFishing()
    if isFishing then return end

    local playerPed = PlayerPedId()
    lastFishingPos = GetEntityCoords(playerPed)

    -- Basic checks
    if IsEntityDead(playerPed) or IsPedInAnyVehicle(playerPed, false) then
        return
    end

    -- Check fishing rod and start sequence
    GetFishingRod(function(rod)
        if not rod then return end

        if fishingData.level < (rod.requiredLevel or 1) then
            ESX.ShowNotification(translate('level_too_low', rod.requiredLevel))
            return
        end

        StartFishingSequence(rod)
    end)
end

-- Fishing sequence
function StartFishingSequence(rod)
    isFishing = true
    local playerPed = PlayerPedId()

    -- Initialize fishing animation
    ClearPedTasks(playerPed)
    SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)
    TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_FISHING", 0, false)

    CreateThread(function()
        -- Show cancel hint in auto mode
        if Config.FishingSettings.autoFishing then
            CreateThread(function()
                while isFishing do
                    ESX.ShowHelpNotification(translate('press_to_cancel'))
                    Wait(0)
                end
            end)
        end

        while isFishing do
            local fishingTime = math.random(5000, 15000)
            local startTime = GetGameTimer()

            -- Fish bite wait period
            while GetGameTimer() - startTime < fishingTime do
                if not isFishing then return end
                
                -- Check for interruptions
                if IsEntityDead(playerPed) or 
                   IsPedInAnyVehicle(playerPed, false) or 
                   #(GetEntityCoords(playerPed) - lastFishingPos) > 3.0 then
                    ESX.ShowNotification(translate('fishing_interrupted'))
                    SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)
                    StopFishing()
                    return
                end
                Wait(100)
            end

            if isFishing then
                -- Attempt catch
                TriggerServerEvent('fishing:attemptCatch', rod.item)
                
                if Config.FishingSettings.autoFishing then
                    SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)
                    ClearPedTasks(playerPed)
                    
                    -- Play waiting animation
                    if not HasAnimDictLoaded(Config.FishingSettings.waitingAnimDict) then
                        RequestAnimDict(Config.FishingSettings.waitingAnimDict)
                        while not HasAnimDictLoaded(Config.FishingSettings.waitingAnimDict) do
                            Wait(100)
                        end
                    end
                    
                    TaskPlayAnim(playerPed, 
                        Config.FishingSettings.waitingAnimDict,
                        Config.FishingSettings.waitingAnim,
                        8.0, -8.0, -1, 1, 0, false, false, false)
                    
                    -- Wait for auto-fishing cooldown
                    Wait(Config.FishingSettings.autoCooldown)
                    
                    -- Resume fishing if not cancelled
                    if isFishing then
                        SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)
                        ClearPedTasks(playerPed)
                        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_FISHING", 0, false)
                    end
                else
                    StopFishing()
                end
            end
        end
    end)
end

-- Stop fishing activity
function StopFishing()
    if not isFishing then return end
    
    isFishing = false
    local playerPed = PlayerPedId()

    SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)    
    ClearPedTasks(playerPed)
    
    ESX.ShowNotification(translate('fishing_stopped'))
end

-- Animation helper functions
function PlayFishingAnimation(animDict, animName, duration)
    local playerPed = PlayerPedId()
    
    -- Load animation dictionary if needed
    if not HasAnimDictLoaded(animDict) then
        RequestAnimDict(animDict)
        while not HasAnimDictLoaded(animDict) do
            Wait(100)
        end
    end

    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, duration or -1, 1, 0, false, false, false)
end

-- Catch result animation
function PlayCatchAnimation(success)
    local playerPed = PlayerPedId()
    SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)
    ClearPedTasks(playerPed)
    
    -- Play success or failure animation
    if success then
        PlayFishingAnimation(ANIMS.SUCCESS, ANIMS.SUCCESS_ACTION, 5000)
    else
        PlayFishingAnimation(ANIMS.FAIL, ANIMS.FAIL_ACTION, 5000)
    end
    
    Wait(2500)
    
    -- Resume fishing if in auto mode
    if isFishing and Config.FishingSettings.autoFishing then
        SetCurrentPedWeapon(playerPed, `WEAPON_UNARMED`, true)
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_FISHING", 0, false)
    end
end

-- Event Handlers
RegisterNetEvent('fishing:catchSuccess')
AddEventHandler('fishing:catchSuccess', function(fish)
    ESX.ShowNotification(translate('fish_caught', fish.name))
    PlayCatchAnimation(true)
end)

RegisterNetEvent('fishing:catchFailed')
AddEventHandler('fishing:catchFailed', function()
    ESX.ShowNotification(translate('fish_got_away'))
    PlayCatchAnimation(false)
end)

RegisterNetEvent('fishing:levelUp')
AddEventHandler('fishing:levelUp', function(newLevel)
    fishingData.level = newLevel
    ESX.ShowNotification(translate('level_up', newLevel))
end)
