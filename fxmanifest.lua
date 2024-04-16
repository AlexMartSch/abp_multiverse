fx_version 'cerulean'
game 'gta5'

name "abp_dimensions"
description "Dimensions manager for FiveM"
author "AlexBanPer"
version "1.0.0"

lua54 'yes'

shared_scripts {
	'shared/*.lua',
	'@ox_lib/init.lua',
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}

files {
	'locales/*.json'
  }