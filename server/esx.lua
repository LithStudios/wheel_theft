if Config.esxSettings.enabled then
    ESX = nil

    if Config.esxSettings.useNewESXExport then
        ESX = exports['es_extended']:getSharedObject()
    else
        Citizen.CreateThread(function()
            while ESX == nil do
                TriggerEvent('esx:getSharedObject', function(obj)
                    ESX = obj
                end)
                Citizen.Wait(0)
            end
        end)
    end

    ESX.RegisterUsableItem(Config.jackStandName, function(source)
        TriggerClientEvent('ls_wheel_theft:LiftVehicle', source)
        UseItem(source)
    end)

    function IsPolice(player)
        local xPlayer = ESX.GetPlayerFromId(player)
        if not xPlayer then
            return false
        end
        local job = xPlayer.getJob()

        return Contains(Config.policeJobNames, job.name)
    end

    function RetrieveItem(source, item)
        local xPlayer = ESX.GetPlayerFromId(source)
        local itemCount = xPlayer.getInventoryItem(item).count
        itemCount = itemCount + 1
        xPlayer.setInventoryItem(item, itemCount)
    end

    function AddMoney(player, amount)
        local xPlayer = ESX.GetPlayerFromId(player)

        if not xPlayer then
            return false
        end

        xPlayer.addAccountMoney(Config.esxSettings.account, amount)
    end

    function UseItem(source)
        local xPlayer = ESX.GetPlayerFromId(source)
        xPlayer.removeInventoryItem(Config.jackStandName, 1)
    end
end