fx_version 'cerulean'
game 'gta5'

name "abp_multiverse"
description "Dimensions manager for FiveM"
author "AlexBanPer"
version "1.0.0"

lua54 'yes'

files {
	'locales/*.json'
}

shared_scripts {
	'@ox_lib/init.lua',
	'shared/*.lua',
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'server/*.lua'
}
