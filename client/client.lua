Keys = {
    ["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
    ["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
    ["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
    ["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
    ["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
    ["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
    ["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
    ["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
    ["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
MISSION_BLIP = nil
MISSION_AREA = nil
sellerBlip = nil
MISSION_ACTIVATED = false
PLAYER_JOB = nil
STORED_WHEELS = {}
WHEEL_PROP = nil
TARGET_VEHICLE = nil

function StartMission()
    MISSION_ACTIVATED = true

    if Config.spawnPickupTruck.enabled then
        SpawnTruck()
    end

    Citizen.CreateThread(function()
        local sleep = 1500
        local vehicleModel = Config.vehicleModels[math.random(1, #Config.vehicleModels)]
        local missionLocation = Config.missionLocations[math.random(1, #Config.missionLocations)]
        local coords = ModifyCoordinatesWithLimits(missionLocation.x, missionLocation.y, missionLocation.z, missionLocation.h)
        local player = PlayerPedId()
        local blip = Config.missionBlip
        MISSION_BLIP = CreateSellerBlip(vector3(coords.x, coords.y, coords.z), blip.blipIcon, blip.blipColor, 1.0, 1.0, blip.blipLabel)
        MISSION_AREA = AddBlipForRadius(coords.x, coords.y, coords.z, 100.0)
        SetBlipAlpha(MISSION_AREA, 150)
        local vehicle = SpawnMissionVehicle(vehicleModel, missionLocation)
        SetCustomRims(vehicle)
        TARGET_VEHICLE = vehicle

        if Config.enableBlipRoute then
            SetBlipRoute(MISSION_BLIP, true)
        end

        ShowTooltip(L('Your target vehicle\'s plate number: ~y~') .. GetVehicleNumberPlateText(vehicle))

        if Config.printLicensePlateToConsole then
            print('Your target vehicle\'s plate number:' .. GetVehicleNumberPlateText(vehicle))
        end

        if Config.debug then
            SetEntityCoords(PlayerPedId(), missionLocation.x + 2.0, missionLocation.y, missionLocation.z, false, false, false, false)
        end

        if not Config.target.enabled then
            while true do
                local playerCoords = GetEntityCoords(player)
                local vehicleCoords = GetEntityCoords(vehicle)
                local distance = #(vehicleCoords - playerCoords)

                if distance < 3.5 then
                    sleep = 1
                    Config.spawnPickupTruck.enabled3DText(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 0.5, L('Lift the car to steal wheels'), 4, 0.035, 0.035)

                    if Entity(vehicle).state.IsVehicleRaised then
                        RemoveBlip(MISSION_BLIP)
                        RemoveBlip(MISSION_AREA)
                        StartWheelTheft(vehicle)
                        break
                    end
                else
                    if IsPedDeadOrDying(PlayerPedId(), 1) then
                        RemoveBlip(MISSION_BLIP)
                        RemoveBlip(MISSION_AREA)
                        CancelMission()
                    end
                end

                Citizen.Wait(sleep)
            end
        else
            --AddEntityToTargeting
        end

    end)
end

function StartWheelTheft(vehicle)
    Citizen.Wait(4000)
    local notified = false

    while true do
        local sleep = 1000
        local playerId = PlayerPedId()
        local playerCoords = GetEntityCoords(playerId)
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(playerCoords - vehicleCoords)

        if distance < 200 and not WHEEL_PROP then
            local wheelCoords, wheelToPlayerDistance, wheelIndex, isWheelMounted = FindNearestWheel(vehicle)

            if isWheelMounted then
                if not Config.target.enabled then
                    sleep = 1
                    Config.spawnPickupTruck.enabled3DText(wheelCoords.x, wheelCoords.y, wheelCoords.z, 'Press ~g~[~w~E~g~]~w~ to start stealing', 4, 0.035, 0.035)

                    if IsControlJustReleased(0, Keys['E']) then
                        if IsPoliceNotified() then
                            notified = true

                            if Config.dispatch.notifyThief then
                                StartVehicleAlarm(vehicle)
                            end

                            TriggerDispatch(GetEntityCoords(PlayerPedId()))
                        end
                        StartWheelDismount(vehicle, wheelIndex, false, true, false)
                    end
                else
                    -- Target
                end
            end

            if #STORED_WHEELS == 4 then
                ShowTooltip(L('Head to ~g~ Wheel Seller ~w~ to complete mission'))
                EnableSale()
                StopWheelTheft(vehicle)

                return
            end
        else
            --stop wheel theft and cancel mission
        end

        Citizen.Wait(sleep)
    end
end

print(GetResourceState('ls_wheelspacers') == 'started')
if GetResourceState('ls_wheelspacers') ~= 'started' then
    print('lets goo')
    Citizen.CreateThread(function()
        local permTable = Config.jackSystem['lower']

        while true do
            local sleep = 1500
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)

            if permTable.everyone or CanPlayerLowerThisCar() then
                local vehicle, isRaised = NearestVehicleCached(coords, 3.0)

                if vehicle and isRaised then
                    sleep = 1
                    local vehicleCoords = GetEntityCoords(vehicle)
                    Draw3DText(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 0.5, L('Press ~g~[~w~E~g~]~w~ to lower this vehicle'), 4, 0.065, 0.065)

                    if IsControlJustReleased(0, Keys['E']) then
                        LowerVehicle(false, true)
                    end
                end
            end

            Citizen.Wait(sleep)
        end
    end)
end

function CanPlayerLowerThisCar()
    local permTable = Config.jackSystem['lower']

    return UseCache('jobCache', function()
        return Contains(permTable.jobs, PLAYER_JOB)
    end, 500)
end

function NearestVehicleCached(coords, radius)
    return UseCache('nearestCacheVehicle', function()
        local vehicle = GetNearestVehicle(coords.x, coords.y, coords.z, radius)

        if vehicle then
            return vehicle, Entity(vehicle).state.IsVehicleRaised
        else
            return vehicle
        end

    end, 500)
end

function StopWheelTheft(vehicle)
    Citizen.CreateThread(function()

        while true do
            local sleep = 1000
            local player = PlayerPedId()
            local playerCoords = GetEntityCoords(player)
            local vehicleCoords = GetEntityCoords(vehicle)

            if #(vehicleCoords - playerCoords) < 3.5 then
                sleep = 1
                Draw3DText(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z + 0.5, L('Press ~g~[~w~E~g~]~w~ to finish stealing'), 4, 0.035, 0.035)

                if IsControlJustReleased(0, Keys['E']) then
                    local lowered = LowerVehicle()

                    while not lowered do
                        Citizen.Wait(100)
                    end

                    SpawnBricksUnderVehicle(vehicle)
                    TriggerServerEvent('ls_wheel_theft:RetrieveItem', Config.jackStandName)

                    break
                end
            end


            Citizen.Wait(sleep)
        end

        SetEntityAsNoLongerNeeded(vehicle)
    end)
end

function IsPoliceNotified()
    if not Config.dispatch.enabled then
        return false
    end

    local alertChance = Config.dispatch.alertChance
    local random = math.random(1,100)

    if random <= alertChance then
        return true
    else
        return false
    end
end

function BeginWheelLoadingIntoTruck(wheelProp)
    if not Config.target.enabled then
        Citizen.CreateThread(function()
            while true do
                local sleep = 300
                local player = PlayerPedId()
                local playerCoords = GetEntityCoords(player)
                local vehicle = GetNearestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0)

                if vehicle and IsVehicleATruck(vehicle) then
                    sleep = 1
                    local textCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -1.5, 0.2)
                    Draw3DText(textCoords.x, textCoords.y, textCoords.z + 0.5, L('Press ~g~[~w~E~g~]~w~ to store the wheel'), 4, 0.035, 0.035)

                    if IsControlJustReleased(0, Keys['E']) then
                        local storedWheel = PutWheelInTruckBed(vehicle, #STORED_WHEELS + 1)
                        DeleteEntity(wheelProp)
                        ClearPedTasksImmediately(player)
                        table.insert(STORED_WHEELS, storedWheel)
                        WHEEL_PROP = nil

                        return
                    end
                end

                Citizen.Wait(sleep)
            end
        end)
    else
        --target implemenation
        -- target vehicle, canInteract if carrying wheel prop
    end
end

function EnableWheelTakeOut()
    if not Config.target.enabled then
        Citizen.CreateThread(function()
            local player = PlayerPedId()

            while #STORED_WHEELS > 0 do
                local sleep = 1000
                local playerCoords = GetEntityCoords(player)
                local vehicle = GetNearestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0)
                local vehicleCoords = GetEntityCoords(vehicle)

                if IsVehicleATruck(vehicle) and not IsPedInAnyVehicle(player, true) and #(vehicleCoords - playerCoords) < 3.5 then
                    sleep = 1
                    local textCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -1.5, 0.2)
                    Draw3DText(textCoords.x, textCoords.y, textCoords.z + 0.5, L('Press ~g~[~w~H~g~]~w~ to take Wheel out'), 4, 0.035, 0.035)

                    if IsControlJustReleased(0, Keys['H']) and not HOLDING_WHEEL then
                        local wheelProp = PutWheelInHands()
                        HOLDING_WHEEL = wheelProp
                        DeleteEntity(STORED_WHEELS[#STORED_WHEELS])
                        table.remove(STORED_WHEELS, #STORED_WHEELS)
                    end
                end

                Citizen.Wait(sleep)
            end
        end)
    else
        -- Target implementation
    end
end

function StartWheelDismount(vehicle, wheelIndex, mount, TaskPlayerGoToWheel, coordsTable)
    local success = exports['ls_bolt_minigame']:BoltMinigame(vehicle, wheelIndex, mount, TaskPlayerGoToWheel, coordsTable)

    if success then
        SetVehicleWheelXOffset(vehicle, wheelIndex, 9999999.0)
        WHEEL_PROP = PutWheelInHands()
        BeginWheelLoadingIntoTruck(WHEEL_PROP)
    end
end

function IsVehicleATruck(vehicle)
    return UseCache('isVehicleATruck', function()
        local pickupTruckHashes = {
            GetHashKey("bison"),    GetHashKey("bobcatxl"),    GetHashKey("crusader"),
            GetHashKey("dubsta3"),    GetHashKey("rancherxl"),    GetHashKey("sandking"),
            GetHashKey("sandking2"),    GetHashKey("rebel"),    GetHashKey("rebel2"),
            GetHashKey("kamacho"),    GetHashKey("youga2"),    GetHashKey("monster"),
            GetHashKey("bison3"),    GetHashKey("bodhi2"),    GetHashKey("Sadler")
        }

        return Contains(pickupTruckHashes, GetEntityModel(vehicle))
    end, 500)
end

RegisterNetEvent('ls_wheel_theft:LiftVehicle')
AddEventHandler('ls_wheel_theft:LiftVehicle', function()
    RaiseCar()
    TriggerServerEvent('ls_wheel_theft:ResetPlayerState', NetworkGetNetworkIdFromEntity(PlayerPedId()))
end)

RegisterNetEvent('ls_wheel_theft:LowerVehicle')
AddEventHandler('ls_wheel_theft:LowerVehicle', function()
    LowerVehicle()
end)

if Config.command.enabled then
    RegisterCommand(Config.command.name, function()
        RaiseCar()
        TriggerServerEvent('ls_wheel_theft:ResetPlayerState', NetworkGetNetworkIdFromEntity(PlayerPedId()))
    end)
end