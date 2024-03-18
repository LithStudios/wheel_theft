local policeBlips = {}

RegisterNetEvent('ls_wheel_theft:TriggerDispatchMessage')
AddEventHandler('ls_wheel_theft:TriggerDispatchMessage', function(eventCoords)
    local system = Config.dispatch.system
    local blipData = Config.dispatch.blip

    if system == 'ps-dispatch' then
        exports['ps-dispatch']:CustomAlert({
            coords = eventCoords,
            message = Config.dispatch.eventName,
            dispatchCode = Config.dispatch.policeCode,
            description = Config.dispatch.description,
            radius = 0,
            sprite = blipData.sprite,
            color = blipData.color,
            scale = blipData.scale,
            length = 3,
            recipientList = Config.policeJobs
        })

    elseif system == 'core-dispatch-old' then
        local hash, _ = GetStreetNameAtCoord(eventCoords.x, eventCoords.y, eventCoords.z)
        local street = GetStreetNameFromHashKey(hash)
        for _, job in ipairs(Config.policeJobs) do
            TriggerServerEvent(
                    'core_dispatch:addCall',
                    Config.dispatch.policeCode,
                    Config.dispatch.eventName,
                    {{icon = 'fa-solid fa-user-police', info=street}},
                    {eventCoords[1], eventCoords[2], eventCoords[3]},
                    job,
                    blipData.timeout * 1000,
                    blipData.sprite,
                    blipData.color
            )
        end
    elseif system == 'core-dispatch-new' then
        local hash, _ = GetStreetNameAtCoord(eventCoords.x, eventCoords.y, eventCoords.z)
        local street = GetStreetNameFromHashKey(hash)
        for _, job in ipairs(Config.policeJobs) do
            exports['core_dispach']:addCall(
                    Config.dispatch.policeCode,
                    Config.dispatch.eventName,
                    {
                        {icon = 'fa-map-signs', info=street}
                    },
                    {eventCoords[1], eventCoords[2], eventCoords[3]},
                    job,
                    blipData.timeout * 1000,
                    blipData.sprite,
                    blipData.color
            )
        end

    elseif system == 'cd-dispatch' then
        local hash, _ = GetStreetNameAtCoord(eventCoords.x, eventCoords.y, eventCoords.z)
        local street = GetStreetNameFromHashKey(hash)

        exports['cd_dispatch']:GetPlayerInfo()
        TriggerServerEvent('cd_dispatch:AddNotification', {
            job_table = Config.policeJobs,
            coords = eventCoords,
            title = Config.dispatch.policeCode,
            message = Config.dispatch.eventName .. ' at '.. street,
            flash = 0,
            unique_id = 'ls_wheel_theft_' .. tostring(math.random(0000000,9999999)),
            blip = {
                sprite = blipData.sprite,
                scale = blipData.scale,
                colour = blipData.color,
                flashes = blipData.showRadar,
                text = Config.dispatch.eventName,
                time = blipData.timeout * 1000,
                sound = 1,
            }
        })
    end
end)

RegisterNetEvent('ls_wheel_theft:activatePoliceAlarm')
AddEventHandler('ls_wheel_theft:activatePoliceAlarm', function(locationCoords)
    PoliceAlarm(locationCoords)
    local streetNameHash
    local intersectionNameHash
    streetNameHash, intersectionNameHash = GetStreetNameAtCoord(locationCoords.x, locationCoords.y, locationCoords.z)
    local streetName = GetStreetNameFromHashKey(streetNameHash)
    DisplayAlert(L('Theft commited at ~y~') .. streetName .. L('. ~w~ Proceed with caution!'), 'Police Dispatch')
    Wait(15000)
    ClearPoliceBlips()
end)

function DisplayAlert(message, subtitle)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)

    -- Set the notification icon, title and subtitle.
    local title = 'Crime In Progress'
    local iconType = 0
    local flash = false -- Flash doesn't seem to work no matter what.
    EndTextCommandThefeedPostMessagetext('CHAR_CALL911', 'CHAR_CALL911', flash, iconType, title, subtitle)

    -- Draw the notification
    local showInBrief = true
    local blink = false -- blink doesn't work when using icon notifications.
    EndTextCommandThefeedPostTicker(blink, showInBrief)
end

function PoliceAlarm(locationCoords)
    local blipConf = Config.blips.policeBlip
    local blip = CreatePoliceBlip(locationCoords, blipConf.sprite, blipConf.color, blipConf.alpha, blipConf.scale, L('Valuables thief'))
    SetBlipDisplay(blip, 8)
    table.insert(policeBlips, blip)
end

function TriggerDispatch(coords)
    TriggerServerEvent('ls_wheel_theft:PoliceAlert', json.encode(coords))
end

function ClearPoliceBlips()
    for k, blip in pairs(policeBlips) do
        RemoveBlip(blip)
    end
    policeBlips = {}
end

function CreatePoliceBlip(coords, sprite, color, alpha, scale, message)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

    SetBlipSprite(blip, sprite)
    SetBlipHighDetail(blip, true)
    SetBlipColour(blip, color)
    SetBlipAlpha(blip, alpha)
    SetBlipScale(blip, scale)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentString(message)
    EndTextCommandSetBlipName(blip)
    return blip
end
