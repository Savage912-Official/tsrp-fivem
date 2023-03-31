---@diagnostic disable: undefined-global

fx_version "cerulean"
games { "gta5" }
lua54 "yes"

author "open_mailbox <dev@open-mailbox.com>"
description "Makes in-game weapons/ammo available to the inventory system."
version "0.0.1"

dependencies {
    "inventory",
    "progress"
}

client_scripts {
    "@common/shared/colors.lua",
    "@common/shared/events.lua",
    "@common/shared/logging.lua",
    "@common/shared/weapons.lua",
    "shared/**/*.lua",
    "client/**/*.lua"
}

server_scripts {
    "@common/shared/colors.lua",
    "@common/shared/events.lua",
    "@common/shared/logging.lua",
    "@common/shared/weapons.lua",
    "shared/**/*.lua",
    "server/**/*.lua"
}
