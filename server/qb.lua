if Config.qbSettings.enabled then

    if Config.qbSettings.useNewQBExport then
        QBCore = exports['qb-core']:GetCoreObject()
    end

    function AddMoney(player, amount)
        local xPlayer = QBCore.Functions.GetPlayer(player)

        if not xPlayer then
            return false
        end

        xPlayer.Functions.AddMoney(Config.qbSettings.moneyAccount, amount)
    end

    QBCore.Functions.CreateUseableItem(Config.jackStandName, function(source)
        if GetResourceState('ls_wheelspacers') == 'started' then
            TriggerClientEvent('ls_wheel_theft:LiftVehicle', source)
            UseItem(source)
            Player(source).state.WheelTheftMission = true
        else
            TriggerClientEvent('ls_wheel_theft:LiftVehicle', source)
            UseItem(source)
        end
    end)

    function IsPolice(player)
        local xPlayer = QBCore.Functions.GetPlayer(player)
        if not xPlayer then
            return false
        end

        local job = xPlayer.PlayerData.job

        return Contains(Config.policeJobNames, job.name)
    end

    function RetrieveItem(source, itemId)
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(source))
        xPlayer.Functions.AddItem(itemId, 1)
    end

    function AddMoney(player, amount)
        local xPlayer = QBCore.Functions.GetPlayer(player)
        if not xPlayer then
            return false
        end

        xPlayer.Functions.AddMoney(Config.qbSettings.account, amount)
    end

    function RemovePlayerItem(player, item, amount)
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(player))
        xPlayer.Functions.RemoveItem(item, amount or 1)
    end

    function UseItem(source)
        local xPlayer = QBCore.Functions.GetPlayer(source)

        xPlayer.Functions.RemoveItem(Config.jackStandName, 1)
    end
end
