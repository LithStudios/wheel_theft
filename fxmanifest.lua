fx_version 'cerulean'
games      { 'gta5' }

author 'Lith Studios | Swizz'
description 'Wheel Theft by Lith Studios'
version '1.2.3'

--
-- Server
--

server_scripts {
    'config.lua',
    'server/esx.lua',
    'server/qb.lua',
    'server/server.lua',
}

--
-- Client
--

client_scripts {
    'client/cache.lua',
    'config.lua',
    'client/truckSpawn.lua',
    'client/policeAlert.lua',
    'client/framework_functions/esx.lua',
    'client/framework_functions/qb.lua',
    'client/client.lua',
    'client/functions.lua',
    'client/selling.lua',
    'client/mission.lua',
    'client/jackstand.lua'
}
