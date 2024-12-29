game "gta5"
fx_version "cerulean"
name "um-skateboard"
version "0.0.1"
description "fork jimathy skateboards"

shared_scripts {
    '@ox_lib/init.lua',
    'shared/config.lua'
}

files {
    'shared/controls.lua',
    'shared/handling.lua'
}

client_scripts {
    'bridge/target/*.lua',
    'utils.lua',
    'main/client.lua'
}

server_scripts {
    'bridge/framework/*.lua',
    'main/server.lua',
}

lua54 'yes'
