fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

author 'zRxnx'
description 'Advanced restricted zone system'
version '1.4.1'

dependencies {
    'zrx_utility',
	'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua',
    'configuration/config.lua',
    'configuration/strings.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'configuration/webhook.lua',
    'server/*.lua'
}