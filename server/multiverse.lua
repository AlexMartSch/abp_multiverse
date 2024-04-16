local Worlds = {}
local Verse = lib.class('Verse')

function Verse:constructor()
    for x = 0, Config.LoadWorlds, 1 do
        Worlds[x] = {
            Players = {},
            Entities = {}
        }
    end

    print("[ABP-Dimensions] Multiverse Loaded with " .. #Worlds .. " worlds.")
end

function Verse:getPlayersInWorld(worldId)
    return Worlds[worldId]
end

function Verse:getWorlds()
    return Worlds
end

function Verse:getPlayerWorld(playerId)
    local world = -1
    local playerPosition = -1

    for worldId, worldData in pairs(Worlds) do
        for pIndex, player in pairs(worldData.Players) do
            if player == playerId then
                playerPosition = pIndex
                world = worldId
                break
            end
        end
    end

    return world, playerPosition
end

function Verse:setPlayerWorld(playerId, worldId)
    if worldId > -1 then
        local _playerWorld, _playerPosition = self:getPlayerWorld(playerId)

        if _playerWorld > -1 then
            table.remove(Worlds[_playerWorld].Players, _playerPosition)
        end

        if Worlds[worldId] then
            table.insert(Worlds[worldId].Players, playerId)
        else
            Worlds[worldId] = {
                Players = {playerId}
            }
        end

        Player(playerId).state.verse = worldId
        SetPlayerRoutingBucket(playerId, worldId)

        return true
    end
    return false
end

function Verse:getEntityWorld(entityId)
    local world = -1
    local entityPosition = -1

    for worldId, worldData in pairs(Worlds) do
        for eIndex, entity in pairs(worldData.Entities) do
            if entity == entityId then
                entityPosition = eIndex
                world = worldId
                break
            end
        end
    end

    return world, entityPosition
end


function Verse:setEntityWorld(entityId, worldId)
    if worldId > -1 then
        local _entityWorld, _entityPosition = self:getEntityWorld(entityId)

        if _entityWorld > -1 then
            table.remove(Worlds[_entityWorld], _entityPosition)
        end

        if Worlds[worldId] then
            table.insert(Worlds[worldId].Entities, entityId)
        else
            Worlds[worldId] = {
                Entities = {entityId}
            }
        end

        SetEntityRoutingBucket(entityId, worldId)

        return true
    end
    return false
end

function Verse:setAllPlayersToDefaultWorld()
    print("[ABP-Dimensions] Set players to world zero.")
    local players = GetPlayers()

    for _, playerId in pairs(players) do
        self:setPlayerWorld(playerId, 0)
    end
end

---------------
Multiverse = Verse:new()


if Config.SetPlayersToDefaultWorldOnResourceStart then
    Multiverse:setAllPlayersToDefaultWorld()
end



--- EXPORTS

exports('GetPlayerWorld', function(playerId) 
    return Multiverse:getPlayerWorld(playerId)
end)


exports('GetPlayersInWorld', function(worldId)
    return Multiverse:getPlayersInWorld(worldId)
end)

exports('GetPlayersInWorlds', function()
    return Multiverse:getWorlds()
end)

exports('SetPlayerWorld', function(playerId, worldId)
    return Multiverse:setPlayerWorld(playerId, worldId)
end)

exports('SetAllPlayersToDefaultWorld', function()
    return Multiverse:setAllPlayersToDefaultWorld()
end)


--- Events

lib.callback.register('abp:Verse:SetPlayerWorldTo', function(source, worldId, vehicleData) 
    local src = source

    if vehicleData then
        local ped = GetPlayerPed(src)
        local vehicle = GetVehiclePedIsIn(ped, false)
        local seats = vehicleData.Seats

        if not ped then return false end

        Multiverse:setEntityWorld(vehicle, worldId)

        for i = -1, seats, 1 do
            local ped = GetPedInVehicleSeat(vehicle, i)
            if ped > 0 then
                local player = NetworkGetNetworkIdFromEntity(ped)
                Multiverse:setPlayerWorld(player, worldId)
                TaskWarpPedIntoVehicle(ped, vehicle, i)
            end
        end

        return true
    end
    
    return Multiverse:setPlayerWorld(source, worldId)
end)

RegisterNetEvent('playerJoining', function(source)
    local src = source
    Multiverse:setPlayerWorld(src, 0)
end)

RegisterNetEvent('abp:Multiverse:SetPlayerInWorld', function(target, world)
    local src = target or source
    Multiverse:setPlayerWorld(src, world)
end)

RegisterNetEvent('abp:Multiverse:ResetPlayerWorld', function(target)
    local src = target or source
    Multiverse:setPlayerWorld(src, 0)
end)

RegisterNetEvent('abp:Multiverse:ResetEntityWorld', function(target)
    local src = target or source
    Multiverse:setEntityWorld(src, 0)
end)