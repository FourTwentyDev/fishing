-- client.lua
ESX = exports["es_extended"]:getSharedObject()
local isFishing = false
local currentZone = nil
local fishingData = {level = 1, xp = 0}


-- Initialize
CreateThread(function()
    -- Get initial fishing data
    ESX.TriggerServerCallback('fishing:getPlayerData', function(data)
        fishingData = data
    end)
    
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local wait = 1000
        
        -- Überprüfen, ob der Spieler lebt, nicht in einem Fahrzeug sitzt und keine anderen Aktivitäten ausführt
        if not IsEntityDead(playerPed) and not IsPedInAnyVehicle(playerPed, false) and not IsPedSwimming(playerPed) then
            -- Check if player is in fishing zone
            for _, zone in pairs(Config.FishingZones) do
                local distance = #(playerCoords - zone.coords)
                if distance <= zone.radius then
                    currentZone = zone
                    wait = 0
                    if not isFishing then
                        DrawText3D(playerCoords.x, playerCoords.y, playerCoords.z, translate('press_start_fishing'))
                        if IsControlJustPressed(0, 38) then -- E key
                            StartFishing()
                        end
                    end
                    break
                end
            end
            
            -- Check sell point
            local sellDistance = #(playerCoords - Config.SellPoint.coords)
            if sellDistance < 3.0 then
                wait = 0
                DrawText3D(Config.SellPoint.coords.x, Config.SellPoint.coords.y, Config.SellPoint.coords.z, translate('press_sell_fish'))
                if IsControlJustPressed(0, 38) then
                    TriggerServerEvent('fishing:sellFish')
                end
            end
        end

        if wait == 1000 then
            currentZone = nil
        end
        
        Wait(wait)
    end
end)

-- Create blips
CreateThread(function()
    -- Create Fish Market blip
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
        -- Create radius blip
        local radiusBlip = AddBlipForRadius(zone.coords, zone.radius)
        SetBlipRotation(radiusBlip, 0)
        SetBlipColour(radiusBlip, zone.blipColor)
        SetBlipAlpha(radiusBlip, zone.blipAlpha)
        
        -- Create center blip
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
    
    -- Create NPC
    RequestModel(GetHashKey(Config.SellPoint.npcModel))
    while not HasModelLoaded(GetHashKey(Config.SellPoint.npcModel)) do
        Wait(1)
    end
    
    local npc = CreatePed(4, GetHashKey(Config.SellPoint.npcModel), Config.SellPoint.coords, 0.0, false, true)
    FreezeEntityPosition(npc, true)
    SetEntityInvincible(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
end)

function GetFishingRod(cb)
    -- Erstelle eine Kopie der Angelruten und sortiere sie nach 'requiredLevel' absteigend
    local sortedFishingRods = {}
    for i = 1, #Config.FishingRods do
        sortedFishingRods[i] = Config.FishingRods[i]
    end

    table.sort(sortedFishingRods, function(a, b)
        return a.requiredLevel > b.requiredLevel
    end)

    local bestRod = nil
    local canUseRod = false
    local rodCount = 0

    -- Iteriere durch die sortierte Liste und wähle die beste nutzbare Angelrute
    for _, fishingRod in pairs(sortedFishingRods) do
        ESX.TriggerServerCallback('fishing:getRodCount', function(count)
            rodCount = rodCount + 1  -- Zähle die geprüften Angelruten

            if count > 0 then
                -- Prüfe, ob der Spieler das benötigte Level hat, um diese Angelrute zu nutzen
                if fishingData.level >= (fishingRod.requiredLevel or 1) then
                    bestRod = fishingRod  -- Wähle die beste nutzbare Angelrute
                    canUseRod = true
                    cb(bestRod)
                    return
                else
                    -- Spieler hat eine Angelrute, aber Level zu niedrig
                    bestRod = fishingRod  -- Wähle die beste verfügbare Rute, auch wenn Level zu niedrig
                end
            end

            -- Wenn alle Angelruten überprüft wurden und keine nutzbar ist, sende eine Notify
            if rodCount == #sortedFishingRods and not canUseRod then
                if bestRod then
                    ESX.ShowNotification(translate('level_too_low', bestRod.requiredLevel))  -- Level zu niedrig für die beste Rute
                else
                    ESX.ShowNotification(translate('need_rod'))  -- Keine Angelrute im Inventar
                end
                cb(nil)
            end
        end, fishingRod.item)
    end
end


function StartFishing()
    if isFishing then return end

    local playerPed = PlayerPedId()

    -- Überprüfen, ob der Spieler lebt
    if IsEntityDead(playerPed) then
        return
    end

    -- Überprüfen, ob der Spieler in einem Fahrzeug sitzt
    if IsPedInAnyVehicle(playerPed, false) then
        return
    end

    GetFishingRod(function(rod)
        if not rod then
            ESX.ShowNotification(translate('need_rod'))
            return
        end

        if fishingData.level < (rod.requiredLevel or 1) then
            ESX.ShowNotification(translate('level_too_low', rod.requiredLevel))
            return
        end

        isFishing = true

        -- Animation starten
        TaskStartScenarioInPlace(playerPed, "WORLD_HUMAN_STAND_FISHING", 0, true)

        -- Fishing Minigame/Timer
        CreateThread(function()
            local fishingTime = math.random(5000, 15000)
            local startTime = GetGameTimer()

            while GetGameTimer() - startTime < fishingTime do
                -- Überprüfung, ob der Spieler weiterhin angelt und nicht unterbrochen wird
                if not isFishing then return end
                if IsEntityDead(playerPed) or IsPedInAnyVehicle(playerPed, false) then
                    ESX.ShowNotification(translate('fishing_interrupted'))
                    isFishing = false
                    ClearPedTasks(playerPed)
                    return
                end
                Wait(100)
            end

            if isFishing then
                -- Erfolgreicher Fang, sende den Versuch an den Server
                TriggerServerEvent('fishing:attemptCatch', rod.item)
                isFishing = false

                -- Entferne die Angelrute aus der Hand (beende die Animation korrekt)
                RemoveFishingRodFromHand()

                -- Stoppe die Angel-Animation
                ClearPedTasks(playerPed)
            end
        end)
    end)
end


function RemoveFishingRodFromHand()
    local playerPed = PlayerPedId()
    SetCurrentPedWeapon(playerPed, GetHashKey("WEAPON_UNARMED"), true)
end


-- Events
RegisterNetEvent('fishing:catchSuccess')
AddEventHandler('fishing:catchSuccess', function(fish)
    ESX.ShowNotification(translate('fish_caught', fish.name))
end)

RegisterNetEvent('fishing:catchFailed')
AddEventHandler('fishing:catchFailed', function()
    ESX.ShowNotification(translate('fish_got_away'))
end)

RegisterNetEvent('fishing:sellComplete')
AddEventHandler('fishing:sellComplete', function(earnings)
    ESX.ShowNotification(translate('fish_sold', earnings))
end)

RegisterNetEvent('fishing:levelUp')
AddEventHandler('fishing:levelUp', function(newLevel)
    fishingData.level = newLevel
    ESX.ShowNotification(translate('level_up', newLevel))
end)