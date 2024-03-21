-- This function is responsible for all the tooltips displayed on top right of the screen, you could
-- replace it with a custom notification etc.
function ShowTooltip(message)
    SetTextComponentFormat("STRING")
    AddTextComponentString(message)
    EndTextCommandDisplayHelp(0, 0, 0, -1)
end

function Contains(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function CreateSellerBlip(coords, sprite, color, alpha, scale, message)
    local blip = AddBlipForCoord(coords)

    SetBlipSprite(blip, sprite)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, color)
    SetBlipAlpha(blip, alpha)
    SetBlipScale(blip, scale)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(message)
    EndTextCommandSetBlipName(blip)
    SetBlipAsShortRange(blip, true)

    return blip
end

function SetCustomRims(vehicle)
    local wheelindex = GetVehicleMod(vehicle, 23)
    SetVehicleModKit(vehicle, 0)
    SetVehicleWheelType(vehicle, math.random(1, 10))
    SetVehicleMod(vehicle, 23, 0, false)
    ToggleVehicleMod(vehicle, 23, true)
end

function RetrieveMoney(sellingKey, sellingPed)

    local playerPed = PlayerPedId()

    ClearPedTasks(sellingPed)
    TaskTurnPedToFaceEntity(playerPed, sellingPed, 1000)
    Citizen.Wait(1000)

    ClearPedTasksImmediately(sellingPed)
    PlayAnim('mp_common', 'givetake2_b', 0, sellingPed)
    PlayAnim('mp_common', 'givetake1_a')

    Citizen.Wait(1000)

    ClearPedTasks(playerPed)
    TaskStartScenarioInPlace(sellingPed, "WORLD_HUMAN_GUARD_STAND", 0, true)
    TriggerServerEvent('ls_wheel_theft:Sell', sellingKey)
end

function PlayAnim(dict, anim)
    Citizen.CreateThread(function()
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(100)
        end
        TaskPlayAnim(PlayerPedId(), dict, anim, 2.0, 1000.0, 2.0, 2, 0, true, true, false)
        RemoveAnimDict(dict)
    end)
end

function GetNearestVehicle(x, y, z, radius)
    local coords = vector3(x, y, z)
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)
        if (closestDistance == -1 or closestDistance > distance) and distance <= radius then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end

    if closestVehicle == -1 then
        return nil
    end

    return closestVehicle, NetworkGetNetworkIdFromEntity(closestVehicle)
end

function SpawnMissionVehicle(modelName, coords, preventNearbyCarDeletion, preventCarLock)
    RequestModel(modelName)
    while not HasModelLoaded(modelName) do
        Citizen.Wait(100)
    end

    local vehicle = CreateVehicle(modelName, coords.x, coords.y, coords.z + 1.5, coords.h, true, false)

    -- Delete nearby entities within the specified radius
    if preventNearbyCarDeletion then
        return vehicle
    end

    local nearbyVehicles = GetVehiclesInRadius(GetEntityCoords(vehicle), 2.0)

    for _, entity in pairs(nearbyVehicles) do
        if entity ~= vehicle then
            SetEntityAsMissionEntity(entity, true, true)
            DeleteEntity(entity)
        end
    end

    if preventCarLock then
        return vehicle
    end

    SetVehicleDoorsLocked(vehicle, 2)

    return vehicle
end

function PutWheelInHands()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    RequestModel(Settings.wheelTakeOff.wheelModel)

    while not HasModelLoaded(Settings.wheelTakeOff.wheelModel) do
        Citizen.Wait(100)
    end

    local wheel = CreateObject(GetHashKey(Settings.wheelTakeOff.wheelModel), playerCoords.x, playerCoords.y, playerCoords.z, true, true, true)

    local handBone = Settings.wheelTakeOff.wheelOffset.bone
    local offsetCoords = Settings.wheelTakeOff.wheelOffset.loc
    local offsetRot = Settings.wheelTakeOff.wheelOffset.rot
    local handBoneIndex = GetPedBoneIndex(playerPed, handBone)
    AttachEntityToEntity(wheel, playerPed, handBoneIndex, offsetCoords.x, offsetCoords.y, offsetCoords.z, offsetRot.x, offsetRot.y, offsetRot.z, true, false, false, false, 2, true)

    PlayAnimFree('anim@heists@box_carry@', 'idle')

    return wheel
end

function SpawnProp(prop, coords)
    RequestModel(prop)
    while not HasModelLoaded(prop) do
        Citizen.Wait(100)
    end

    local object = CreateObject(GetHashKey(prop), coords.x, coords.y, coords.z, true, true, true)

    return object
end

function DropOffWheel(crateProp, wheelIndex)
    local zTable = {0.15, 0.35, 0.55, 0.75}
    AttachEntityToEntity(HOLDING_WHEEL, crateProp, 0, 0.0, 0.0, zTable[wheelIndex], -90.0, 0.0, 0.0, true, true, false, false, 2, true)
    HOLDING_WHEEL = false
    ClearPedTasksImmediately(PlayerPedId())
end

function PutWheelInTruckBed(vehicle, wheelCount)
    local zTable = {0.4, 0.6, 0.8, 1.0}
    local vehicleBedCoords = GetOffsetFromEntityInWorldCoords(vehicle, 0.0, -1.5, 0.2)
    local wheel = CreateObject(GetHashKey(Settings.wheelTakeOff.wheelModel), vehicleBedCoords.x, vehicleBedCoords.y, vehicleBedCoords.z, true, true, true)

    local handBone = 0
    local offsetCoords = vector3(0.0, -1.5, zTable[wheelCount])
    local offsetRot = vector3(-90.0, 0.0, 0.0)
    local handBoneIndex = 0
    SetEntityCollision(wheel, true, true)
    AttachEntityToEntity(wheel, vehicle, handBoneIndex, offsetCoords.x, offsetCoords.y, offsetCoords.z, offsetRot.x, offsetRot.y, offsetRot.z, true, true, false, false, 2, true)

    PlayAnimFree('anim@heists@box_carry@', 'idle')

    return wheel
end

function PlayAnimFree(dict, anim)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Citizen.Wait(100)
    end
    TaskPlayAnim(PlayerPedId(), dict, anim, 5.0, 1.0, 5000.0, 49, 0.0, false, false, false)
    RemoveAnimDict(dict)
end

function GetVehiclesInRadius(coords, radius)
    local vehicles = GetGamePool('CVehicle')
    local vehiclesInRadius = {}

    for i = 1, #vehicles, 1 do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(vehicleCoords - coords)

        if distance <= radius then
            table.insert(vehiclesInRadius, vehicles[i])
        end
    end

    return vehiclesInRadius
end

function Draw3DText(x, y, z, textInput, fontId, scaleX, scaleY)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, true)
    local scale = (1 / dist) * 20
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov
    SetTextScale(scaleX * scale, scaleY * scale)
    SetTextFont(fontId)
    SetTextProportional(1)
    SetTextDropshadow(1, 1, 1, 1, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(textInput)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    ClearDrawOrigin()
end

function FindNearestWheel(vehicle)
    local player = PlayerPedId(-1)
    local distance = 1000
    local pCoords = GetEntityCoords(player)
    local boneCoords = nil
    local coords = nil
    local wheelIndex = nil
    local isWheelMounted = true

    local bones = {'wheel_lf','wheel_rf', 'wheel_lr', 'wheel_rr'}
    local suspensionBones = {'suspension_lf','suspension_rf', 'suspension_lr', 'suspension_rr'}
    local min, max = GetModelDimensions(GetEntityModel(vehicle))

    local wheels = {
        {
            x = min.x,
            y = max.y - 0.7,
            z = min.z
        },
        {
            x = max.x,
            y = max.y - 0.7,
            z = min.z
        },
        {
            x = min.x,
            y = min.y + 0.7,
            z = min.z
        },
        {
            x = max.x,
            y = min.y + 0.7,
            z = min.z
        }
    }

    for i, wheel in pairs(wheels) do
        local wheelCoords = GetOffsetFromEntityInWorldCoords(vehicle, wheel.x, wheel.y, wheel.z)
        local wheelToPlayerDistance = GetDistanceBetweenCoords(pCoords.x, pCoords.y, pCoords.z, wheelCoords.x, wheelCoords.y, wheelCoords.z)

        if wheelToPlayerDistance < distance then
            distance = wheelToPlayerDistance
            wheelIndex = i - 1
            coords = wheelCoords
        end
    end

    if distance == 1000 then
        return false
    end

    local boneId = GetEntityBoneIndexByName(vehicle, bones[wheelIndex + 1])
    if not boneId then
        return false
    end
    boneCoords = GetWorldPositionOfEntityBone(vehicle, boneId)

    local realCoords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, suspensionBones[wheelIndex + 1]))

    if realCoords.x ~= 0.0 and realCoords.y ~= 0.0 then
        coords = realCoords
    end

    local chassisBone = GetEntityBoneIndexByName(vehicle, 'chassis_dummy')
    local chassisCoords = GetWorldPositionOfEntityBone(vehicle, chassisBone)
    local chassisWheelDistance = GetDistanceBetweenCoords(chassisCoords, boneCoords)

    if chassisWheelDistance > 10.0 then
        isWheelMounted = false
    end

    return coords, distance, wheelIndex, isWheelMounted
end

function L(text)
    return Locale[text] or text
end

function SpawnBricksUnderVehicle(vehicle)
    local heading = GetEntityHeading(vehicle)
    local headingRadians = math.rad(heading)
    local suspensionBones = {'suspension_lf','suspension_rf', 'suspension_lr', 'suspension_rr'}
    local bricks = {}

    FreezeEntityPosition(vehicle, true)
    SetEntityInvincible(vehicle, true)

    for k = 1, 4, 1 do
        local objectCoords = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle,suspensionBones[k]))
        objectCoords = vector3(objectCoords.x, objectCoords.y, objectCoords.z - 0.3)

        if k % 2 == 0 then
            local leftOffsetX = 0.35 * math.cos(headingRadians)
            local leftOffsetY = 0.15 * math.sin(headingRadians)

            for i = 0, 5, 1 do
                local newCoords = vector3(
                        objectCoords.x + leftOffsetX,
                        objectCoords.y + leftOffsetY,
                        objectCoords.z + i * 0.11
                )

                local brick = SpawnProp('ng_proc_brick_01a', newCoords)

                while not DoesEntityExist(brick) do
                    Citizen.Wait(10)
                end

                table.insert(bricks, brick)
                SetEntityHeading(brick, GetEntityHeading(vehicle))
                FreezeEntityPosition(brick, true)
                SetEntityInvincible(brick, true)
            end
        else
            local leftOffsetX = -0.35 * math.cos(headingRadians)
            local leftOffsetY = -0.15 * math.sin(headingRadians)

            for i = 0, 5, 1 do
                local newCoords = vector3(
                        objectCoords.x + leftOffsetX,
                        objectCoords.y + leftOffsetY,
                        objectCoords.z + i * 0.11
                )

                local brick = SpawnProp('ng_proc_brick_01a', newCoords)

                while not DoesEntityExist(brick) do
                    Citizen.Wait(10)
                end

                table.insert(bricks, brick)
                SetEntityHeading(brick, GetEntityHeading(vehicle))
                FreezeEntityPosition(brick, true)
                SetEntityInvincible(brick, true)
            end
        end
    end
    
    for k=1, #bricks, 1 do
        SetEntityAsNoLongerNeeded(bricks[k])
    end

end

function JobCheck()
    if not Config.job.jobOnly or Contains(Config.job.jobNames, PLAYER_JOB) then
        return true
    end

    return false
end

function SpawnPed(selling)
    local model = selling.pedModel
    local loc = selling.location
    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(100)
    end

    local ped = CreatePed(0, model, loc.x, loc.y, loc.z - 1.0, loc.h, false, false)
    SetModelAsNoLongerNeeded(model)
    SetEntityInvincible(ped, true)
    FreezeEntityPosition(ped, true)

    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_GUARD_STAND", 0, true)
    SetPedCanUseAutoConversationLookat(ped, true)
    TaskLookAtEntity(ped, PlayerPedId(), -1, 2048, 3)
    SetEntityAsMissionEntity(ped, true, true)

    return ped
end

-- Prevents displaying exact coordinates of the vehicle through blip
function ModifyCoordinatesWithLimits(x, y, z, h)
    local offsetX = math.random(-100, 100)
    local offsetY = math.random(-100, 100)
    local offsetZ = math.random(-100, 100)

    -- Ensure the result is not less than -50 or greater than +50
    local additional_x = math.max(-50, math.min(x + offsetX, 50))
    local additional_y  = math.max(-50, math.min(y + offsetY, 50))
    local additional_z  = math.max(-50, math.min(z + offsetZ, 50))

    x = x + additional_x
    y = y + additional_y
    z = z + additional_z

    return {x = x, y = y, z = z, h = h}
end

function DoesVehicleHaveAllWheels(vehicle)
    for k=1, 4, 1 do
        if GetVehicleWheelXOffset(vehicle, k-1) > 300 then
            return false
        end
    end

    return true
end