RegisterServerEvent('ls_wheel_theft:Sell')
AddEventHandler('ls_wheel_theft:Sell', function(sellingKey)
    local _source = source
    local selling = Config.missionPeds[sellingKey]

    AddMoney(_source, selling.price)
end)

RegisterServerEvent('ls_wheel_theft:server:setIsRaised')
AddEventHandler('ls_wheel_theft:server:setIsRaised', function(netId, raised)
    local veh = NetworkGetEntityFromNetworkId(netId)

    if not DoesEntityExist(veh) then
        return
    end

    Entity(veh).state.IsVehicleRaised = raised
end)

RegisterServerEvent('ls_wheel_theft:RetrieveItem')
AddEventHandler('ls_wheel_theft:RetrieveItem', function(itemName)
    local _source = source
    RetrieveItem(_source, itemName)
end)

RegisterServerEvent('ls_wheel_theft:ResetPlayerState')
AddEventHandler('ls_wheel_theft:ResetPlayerState', function(netId)
    local player = NetworkGetEntityFromNetworkId(netId)
    Wait(5000)
    Player(player).state.WheelTheftMission = false
end)

RegisterServerEvent('ls_wheel_theft:server:forceDeleteJackStand')
AddEventHandler('ls_wheel_theft:server:forceDeleteJackStand', function(state)
    local entity = NetworkGetEntityFromNetworkId(state)
    DeleteEntity(entity)
end)

RegisterServerEvent('ls_wheel_theft:server:saveJacks')
AddEventHandler('ls_wheel_theft:server:saveJacks', function(netId, jack1, jack2, jack3, jack4)
    local veh = NetworkGetEntityFromNetworkId(netId)

    if not DoesEntityExist(veh) then
        return
    end

    Entity(veh).state.jackStand1 = jack1
    Entity(veh).state.jackStand2 = jack2
    Entity(veh).state.jackStand3 = jack3
    Entity(veh).state.jackStand4 = jack4
end)
