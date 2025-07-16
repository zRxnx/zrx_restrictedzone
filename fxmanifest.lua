fx_version 'cerulean'
game 'gta5'
lua54 'yes'
use_experimental_fxv2_oal 'yes'

name 'zrx_restrictedzone'
author 'zRxnx'
version '2.1.0'
description 'Advanced restricted zone system'
repository 'https://github.com/zrxnx/zrx_restrictedzone'

docs 'https://docs.zrxnx.at'
discord 'https://discord.zrxnx.at'

dependencies {
    '/server:6116',
    '/onesync',
	'ox_lib'
}

shared_scripts {
    '@ox_lib/init.lua',
    'configuration/*.lua',
    'utils.lua',
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}