function SpawnTruck()
    local truckTable = Config.spawnPickupTruck
    local vehicleModel = truckTable.models[math.random(1, #truckTable.models)]
    local availableSpotIndex = nil

    for k, spawnCoords in pairs(Config.spawnPickupTruck.truckSpawnCoords) do
        if not IsPlaceTaken(k) then
            availableSpotIndex = k
        end
    end

    if not availableSpotIndex then
        ShowTooltip(L('~r~ No seats available at the moment'))

        return
    end

    local vehicle = SpawnMissionVehicle(vehicleModel, truckTable.truckSpawnCoords[availableSpotIndex], true, true)
end

function IsPlaceTaken(index)
    local truckTable = Config.spawnPickupTruck
    local coords = truckTable.truckSpawnCoords[index]

    local vehicle = GetNearestVehicle(coords.x, coords.y, coords.z, 1.0)

    if vehicle then
        return true
    else
        return false
    end
end