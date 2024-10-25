--[[ 
    FourTwenty Development
    discord.gg/fourtwenty
    fourtwenty.dev
]]

fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'fw_fishing'
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

files {}
