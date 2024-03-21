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
        TriggerClientEvent('ls_wheel_theft:LiftVehicle', source)
        UseItem(source)
    end)

    function IsPolice(player)
        local xPlayer = QBCore.Functions.GetPlayer(player)
        if not xPlayer then
            return false
        end

        local job = xPlayer.PlayerData.job

        return Contains(Config.policeJobNames, job.name)
    end

    function RetrieveItem(source, itemId, count)
        local xPlayer = QBCore.Functions.GetPlayer(tonumber(source))

        if count then
            xPlayer.Functions.AddItem(itemId, count)
        else
            xPlayer.Functions.AddItem(itemId, 1)
        end
    end

    function AddMoney(player, amount)
        local xPlayer = QBCore.Functions.GetPlayer(player)
        if not xPlayer then
            return false
        end

        if Config.qbSettings.payInItems.enabled then
            RetrieveItem(player, Config.qbSettings.payInItems.itemName, Config.qbSettings.payInItems.count)
        else
            xPlayer.Functions.AddMoney(Config.qbSettings.account, amount)
        end
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
