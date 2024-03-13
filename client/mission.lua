local cooldown = false

function CreateMissionPed()
    local missionTable = Config.missionPeds['mission_ped']
    local ped = SpawnPed(missionTable)
    local blip = missionTable.blip
    local blipCoords = missionTable.location

    if blip.showBlip then
        CreateSellerBlip(GetEntityCoords(ped), blip.blipIcon, blip.blipColor, 1.0, 1.0, blip.blipLabel)
    end

    EnableMission(ped)
end

function EnableMission(missionPed)
    Citizen.CreateThread(function()
        while true do
            local sleep = 1000
            local player = PlayerPedId()
            local playerCoords = GetEntityCoords(player)
            local missionPedCoords = GetEntityCoords(missionPed)

            if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, missionPedCoords.x, missionPedCoords.y, missionPedCoords.z, false) < 3.0 then
                sleep = 1
                if not MISSION_ACTIVATED then
                    Draw3DText(missionPedCoords.x, missionPedCoords.y, missionPedCoords.z, L('Press ~g~[~w~E~g~]~w~ to start mission'), 4, 0.065, 0.065)

                    if IsControlJustReleased(0, Keys['E']) and not cooldown then
                        SetCooldown(3000)
                        StartMission()
                    end
                else
                    Draw3DText(missionPedCoords.x, missionPedCoords.y, missionPedCoords.z, L('Press ~g~[~w~E~g~]~w~ to cancel mission'), 4, 0.065, 0.065)

                    if IsControlJustReleased(0, Keys['E']) and not cooldown then
                        SetCooldown(3000)
                        CancelMission()
                    end
                end

            end
            Citizen.Wait(sleep)
        end
    end)
end

function CancelMission()
    MISSION_ACTIVATED = false

    if MISSION_BLIP and MISSION_AREA then
        RemoveBlip(MISSION_BLIP)
        RemoveBlip(MISSION_AREA)
    end

end

function SetCooldown(time)
    cooldown = true
    Citizen.CreateThread(function()
        Citizen.Wait(time)
        cooldown = false
    end)
end

CreateMissionPed()