local saleActive = false
local cooldown = false
local sellerBlip = false
HOLDING_WHEEL = nil
local storedWheels = {}

function ContinueSale(sellerPed, crateProp)
    Citizen.CreateThread(function()
        local wheelTakeOutEnabled = false

        ShowTooltip('Put the ~r~ stolen wheels ~w~ in the crate to finish the sale')

        while saleActive do
            local sleep = 1000
            local player = PlayerPedId()
            local playerCoords = GetEntityCoords(player)
            local sellerCoords = GetEntityCoords(sellerPed)
            local crateCoords = GetEntityCoords(crateProp)

            if HOLDING_WHEEL and #storedWheels ~= 4 then
                if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, crateCoords.x, crateCoords.y, crateCoords.z, false) < 3.0 then
                    sleep = 1
                    Draw3DText(crateCoords.x, crateCoords.y, crateCoords.z, L('Press ~g~[~w~E~g~]~w~ to drop off wheel'), 4, 0.065, 0.065)

                    if IsControlJustReleased(0, Keys['E']) and not cooldown then
                        table.insert(storedWheels, HOLDING_WHEEL)
                        SetCooldown(3000)
                        DropOffWheel(crateProp, #storedWheels)
                    end
                end

            elseif #storedWheels == 4 then
                if GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, sellerCoords.x, sellerCoords.y, sellerCoords.z, false) < 3.0 then
                    sleep = 1
                    Draw3DText(sellerCoords.x, sellerCoords.y, sellerCoords.z, L('Press ~g~[~w~E~g~]~w~ to complete the sale'), 4, 0.065, 0.065)

                    if IsControlJustReleased(0, Keys['E']) and not cooldown then
                        SetCooldown(3000)
                        CompleteSale(sellerPed)
                    end
                end
            end

            if not wheelTakeOutEnabled and GetDistanceBetweenCoords(playerCoords.x, playerCoords.y, playerCoords.z, crateCoords.x, crateCoords.y, crateCoords.z, false) < 50.0 then
                EnableWheelTakeOut()
                wheelTakeOutEnabled = true
            end

            Citizen.Wait(sleep)
        end
    end)
end

function CompleteSale(sellerPed)
    saleActive = false
    RetrieveMoney('sale_ped', sellerPed)

    SetEntityAsNoLongerNeeded(sellerPed)

    for k=1, #storedWheels, 1 do
        SetEntityAsNoLongerNeeded(storedWheels[k])
    end

    RemoveBlip(sellerBlip)
    storedWheels = {}
    CancelMission()
end

function EnableSale()
    local sellerTable = Config.missionPeds['sale_ped']
    local ped = SpawnPed(sellerTable)
    local blip = sellerTable.blip
    local cratePropModel = sellerTable.wheelDropOff.crateProp
    local wheelDropOffCoords = sellerTable.wheelDropOff.location
    local crateProp = SpawnProp(cratePropModel, wheelDropOffCoords)

    FreezeEntityPosition(crateProp, true)

    if blip.showBlip then
        sellerBlip = CreateSellerBlip(GetEntityCoords(ped), blip.blipIcon, blip.blipColor, 1.0, 1.0, blip.blipLabel)

        if Config.enableBlipRoute then
            SetBlipRoute(sellerBlip, true)
        end
    end

    saleActive = true
    ContinueSale(ped, crateProp)
end

function SetCooldown(time)
    cooldown = true
    Citizen.CreateThread(function()
        Citizen.Wait(time)
        cooldown = false
    end)
end
