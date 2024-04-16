if Config.Framework ~= "esx" then
    return
end

print("[ABP-Dimensions] Loaded ESX Configuration")
ESX = exports['es_extended']:getSharedObject()
