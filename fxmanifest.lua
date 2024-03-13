fx_version 'cerulean'
games      { 'gta5' }

author 'Lith Studios | Swizz'
description 'Wheel Theft by Lith Studios'
version '1.0.0'

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
    'client/framework_functions/esx.lua',
    'client/framework_functions/qb.lua',
    'client/client.lua',
    'client/functions.lua',
    'client/selling.lua',
    'client/mission.lua',
    'client/jackstand.lua'
}

dependency 'ls_bolt_minigame'
