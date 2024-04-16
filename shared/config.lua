Config = {}

lib.locale()
if not lib.checkDependency('ox_lib', '3.19.2') then return error("Please update OX LIB") end

--[[

           ____  _____        _____                 _                                  _       
     /\   |  _ \|  __ \      |  __ \               | |                                | |      
    /  \  | |_) | |__) |_____| |  | | _____   _____| | ___  _ __  _ __ ___   ___ _ __ | |_ ___ 
   / /\ \ |  _ <|  ___/______| |  | |/ _ \ \ / / _ \ |/ _ \| '_ \| '_ ` _ \ / _ \ '_ \| __/ __|
  / ____ \| |_) | |          | |__| |  __/\ V /  __/ | (_) | |_) | | | | | |  __/ | | | |_\__ \
 /_/    \_\____/|_|          |_____/ \___| \_/ \___|_|\___/| .__/|_| |_| |_|\___|_| |_|\__|___/
                                                           | |                                 
                                                           |_|                                 

    Supported version Octuber 2023
    Support Discord: https://discord.gg/NQFSD6t9hQ

]]

-- Enable/Disable debug mode
Config.DebugMode = true

--- Current Supported options:
--- 'esx' ES Extended
--- 'qb'  QB-Core
--- 'standalone' Standalone configuration 
Config.Framework = "standalone"

-- Preload worlds
-- Note: Apparently in FiveM the worlds are infinite (as far as the maximum value of integers allows) 
--       however, to use this system we limit the worlds to have more exhaustive control.
Config.LoadWorlds = 3016


--- Use travel effect
--- Note: This effect is used when a player travels between worlds
Config.TravelEffect = {
    Enable = true,
    --WIP xSound = false, -- Require xSound
    NativeSound = true, -- Compatible with xSound too
    --WIP Particles = true,
}

Config.Verse = {
    {
        PointA = {
            Position = vector3(-394.3517, 1216.3078, 324.64175),
            Multiverse = 2,
            Marker = {
                Type = 1,
                color = { r = 255, g = 0, b = 0, a = 200 }
            },
            DistanceView = 50
        },
        PointB = {
            Position = vector3(-399.313, 1198.8815, 324.64175),
            Multiverse = 0,
            Marker = {
                Type = 1,
                color = { r = 255, g = 0, b = 0, a = 200 }
            },
            DistanceView = 50
        },
        Allow = {
            Vehicles = true
        },
    }
}