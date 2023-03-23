fx_version 'cerulean'
game 'gta5'

author 'Divalent'
description 'Car Chopping.'
version '1.0.0'

shared_scripts { 'config.lua', '@qb-core/import.lua' }
client_scripts { '@PolyZone/client.lua', '@PolyZone/BoxZone.lua', '@PolyZone/EntityZone.lua', '@PolyZone/CircleZone.lua', '@PolyZone/ComboZone.lua', 'client/*.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/*.lua', }
