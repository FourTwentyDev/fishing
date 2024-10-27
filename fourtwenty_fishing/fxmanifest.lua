--[[ 
    FourTwenty Development
    discord.gg/fourtwenty
    https://fourtwenty.dev
]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'fourtwenty_fishing'
description 'Fishing Script - Catch fish and earn rewards!'
author 'FourTwenty Development'
version '1.0.0'

shared_scripts {
  'shared/*.lua',
  'config.lua'
}

client_scripts {
  'client/*.lua'
}

server_scripts {
  '@oxmysql/lib/MySQL.lua',
  'server/*.lua',
}


ui_page 'web/index.html'

files {
    'web/index.html',
    'web/app.js',
    'web/style.css'
}