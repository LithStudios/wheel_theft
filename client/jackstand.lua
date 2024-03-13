local waitTime = 5
local height = 0.18
-----------------------------------------------------------------------------------------------------------------------------------------------------
-- Function to check if vehicle is a car
-----------------------------------------------------------------------------------------------------------------------------------------------------
IsCar = function(veh)
    local vc = GetVehicleClass(veh)
    return (vc >= 0 and vc <= 7) or (vc >= 9 and vc <= 12) or (vc >= 17 and vc <= 20)
end

function RaiseCar()
    local playerPed = PlayerPedId()
    local pCoords = GetEntityCoords(playerPed)
    local vehicle, netId = GetNearestVehicle(pCoords.x, pCoords.y, pCoords.z, 2.0)

    if not JobCheck() then
        ShowTooltip(L('~r~ You can not do this'))
        return
    end

    if vehicle and IsEntityAVehicle(vehicle) and IsCar(vehicle) and not(IsPedInAnyVehicle(playerPed, false)) and IsVehicleSeatFree(vehicle, -1) and IsVehicleStopped(vehicle) and (not Entity(vehicle).state.IsVehicleRaised) then
        Citizen.CreateThread(function()
            local veh = NetworkGetEntityFromNetworkId(netId)
            NetworkRequestControlOfEntity(veh)

            local timeout = 1500
            while not NetworkHasControlOfEntity(veh) and timeout > 0 do
                Citizen.Wait(100)
                timeout = timeout - 100
            end

            if not NetworkHasControlOfEntity(veh) then
                print('Can\'t get control of the entity')
                return
            end
            
            TriggerServerEvent('ls_wheel_theft:server:setIsRaised', netId, true)

            local vehpos = GetEntityCoords(veh)
            local playerCoords = GetEntityCoords(playerPed)
            local heading = GetHeadingFromVector_2d(playerCoords.x - vehpos.x, playerCoords.y - vehpos.y)
            SetEntityHeading(playerPed, heading)
            PlayAnim('amb@world_human_vehicle_mechanic@male@base', 'base')
            Citizen.Wait(1500)

            FreezeEntityPosition(veh, true)

            local model = 'imp_prop_axel_stand_01a'

            RequestModel(model)

            while not HasModelLoaded(model) do
                Citizen.Wait(0)
            end

            local min, max = GetModelDimensions(GetEntityModel(veh))
            local width = ((max.x - min.x) / 2) - ((max.x - min.x) / 3.3)
            local length = ((max.y - min.y) / 2) - ((max.y - min.y) / 3.3)
            local zOffset = 0.5

            local flWheelStand = CreateObject(GetHashKey(model), vehpos.x - width, vehpos.y + length, vehpos.z - zOffset, true, true, true)

            local frWheelStand = CreateObject(GetHashKey(model), vehpos.x + width, vehpos.y + length, vehpos.z - zOffset, true, true, true)

            local rlWheelStand = CreateObject(GetHashKey(model), vehpos.x - width, vehpos.y - length, vehpos.z - zOffset, true, true, true)

            local rrWheelStand = CreateObject(GetHashKey(model), vehpos.x + width, vehpos.y - length, vehpos.z - zOffset, true, true, true)

            AttachEntityToEntity(flWheelStand, veh, 0, -width, length, -zOffset, 0.0, 0.0, -90.0, false, false, false, false, 0, true)
            FinishJackstand(flWheelStand)

            AttachEntityToEntity(frWheelStand, veh, 0, width, length, -zOffset, 0.0, 0.0, -90.0, false, false, false, false, 0, true)
            FinishJackstand(frWheelStand)

            AttachEntityToEntity(rlWheelStand, veh, 0, -width, -length, -zOffset, 0.0, 0.0, 90.0, false, false, false, false, 0, true)
            FinishJackstand(rlWheelStand)

            AttachEntityToEntity(rrWheelStand, veh, 0, width, -length, -zOffset, 0.0, 0.0, 90.0, false, false, false, false, 0, true)
            FinishJackstand(rrWheelStand)

            Citizen.Wait(100)
            TriggerServerEvent('ls_wheel_theft:server:saveJacks', netId, NetworkGetNetworkIdFromEntity(flWheelStand), NetworkGetNetworkIdFromEntity(frWheelStand), NetworkGetNetworkIdFromEntity(rlWheelStand), NetworkGetNetworkIdFromEntity(rrWheelStand), true)

            local addZ = 0

            while addZ < height do
                addZ = addZ + 0.001
                SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z + addZ, true, true, true)
                Citizen.Wait(waitTime)
            end

            AttachJackToCar(flWheelStand, veh)
            AttachJackToCar(frWheelStand, veh)
            AttachJackToCar(rlWheelStand, veh)
            AttachJackToCar(rrWheelStand, veh)

            Citizen.Wait(1500)
            ClearPedTasks(playerPed)

            --OnVehicleRaised(veh)
        end)
    end
end
function FinishJackstand(object)
    local rot = GetEntityRotation(object, 5)
    DetachEntity(object)
    FreezeEntityPosition(object, true)

    local coords = GetEntityCoords(object)
    local _, ground = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z + 2.0, true)
    SetEntityCoords(object, coords.x, coords.y, ground, false, false, false, false)
    PlaceObjectOnGroundProperly_2(object)
    SetEntityRotation(object, rot.x, rot.y, rot.z, 5, 0)
    SetEntityCollision(object, false, true)
end

function AttachJackToCar(object, vehicle)
    local offset = GetOffsetFromEntityGivenWorldCoords(vehicle, GetEntityCoords(object))

    FreezeEntityPosition(object, false)
    AttachEntityToEntity(object, vehicle, 0, offset, 0.0, 0.0, 90.0, 0, 0, 0, 0, 0, 1)
end

function LowerVehicle(errorCoords)
    working = false

    local playerCoords = GetEntityCoords(PlayerPedId(-1))
    local veh, netId = GetNearestVehicle(playerCoords.x, playerCoords.y, playerCoords.z, 5.0)

    if veh and (Entity(veh).state.IsVehicleRaised or Entity(veh).state.spacerOnKqCarLift) then

        if DoesVehicleHaveAllWheels(veh) then
            ShowTooltip(L('Finish the job'))
            return
        end

        if Entity(veh).state.IsVehicleRaised then
            NetworkRequestControlOfEntity(veh)

            local timeout = 2000
            while not NetworkHasControlOfEntity(veh) and timeout > 0 do
                Citizen.Wait(100)
                timeout = timeout - 100
            end

            local vehpos = GetEntityCoords(veh)

            local removeZ = 0

            while removeZ < 0.18 do
                removeZ = removeZ + 0.001
                SetEntityCoordsNoOffset(veh, vehpos.x, vehpos.y, vehpos.z - removeZ, true, true, true)
                Citizen.Wait(waitTime)
            end

            FreezeEntityPosition(veh, true)

            for i = 4, 1, -1 do
                if Entity(veh).state['jackStand' .. i] then
                    TriggerServerEvent('ls_wheel_theft:server:forceDeleteJackStand', (Entity(veh).state['jackStand' .. i]))
                end
            end

            Citizen.Wait(100)
            FreezeEntityPosition(veh, false)

            TriggerServerEvent('ls_wheel_theft:server:setIsRaised', netId, false)
        else
            TriggerServerEvent('ls_wheel_theft:server:setIsRaised', netId, false, true)
            FreezeEntityPosition(veh, false)
        end

        return true
        --TriggerServerEvent('ls_wheel_theft:RetrieveItem', jackName)
    end
end
