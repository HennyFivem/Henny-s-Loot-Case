fx_version 'cerulean'
game 'gta5'
author 'Henny/Twolley' 
description 'Henny FiveM LootCase Script' 
version '1.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_script 'client/client.lua'
server_script 'server/server.lua'

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/script.js',
    'web/sounds/*.ogg'
}

dependencies {
    'qb-core',
    'ox_inventory',
    'ox_lib'
}