local Multiverse = {}
local timeout = 0

DebugPrint = function(...)
    if Config.DebugMode then
        print("[ABP-Multiverse]",...)
    end
end

if Config.DebugMode then
    RegisterCommand('mv_verse', function() 
        DebugPrint("Dimension:", MyDimension())
    end)
end

MyDimension = function()
    return LocalPlayer.state.verse
end

SetInteractTimeout = function(time)
    timeout = GetGameTimer() + time
end

CanInterct = function()
    return timeout < GetGameTimer()
end

OnInteract = function(destPoint, verseId)

    if not CanInterct() then
        return lib.notify({
            description = locale("INTERACT_TIMEOUT")
        })
    end

    SetInteractTimeout(1000)

    DoScreenFadeOut(800)
    Wait(1000)

    local verse = Multiverse[verseId]
    if not verse then
        return lib.notify({
            description = locale("MULTIVERSE_NOT_FOUND")
        })
    end

    local isPlayerInVehicle = cache.vehicle
    local vehicleData = nil
    if isPlayerInVehicle then
        local vehicle = isPlayerInVehicle
        local seats = GetVehicleModelNumberOfSeats(GetEntityModel(vehicle))
        vehicleData = { 
            Entity = nil,
            Seats = seats
        }
    end

    local destCoords = destPoint.Position
    local success = lib.callback.await('abp:Verse:SetPlayerWorldTo', 200, destPoint.Multiverse, vehicleData)

    local successDimensionChanged = lib.waitFor(function()
        if MyDimension() == destPoint.Multiverse then return true  end
    end, locale("MULTIVERSE_ERROR"), 1500)

    if not success or not successDimensionChanged then
        DoScreenFadeIn(500)
        return lib.notify({
            description = locale("MULTIVERSE_ERROR")
        })
    end


    if Config.TravelEffect.Enable then
        if Config.TravelEffect.NativeSound then
            PlaySoundFrontend(-1, "Zone_Team_Capture", "DLC_Apartments_Drop_Zone_Sounds", 1)
        end
    end

    if isPlayerInVehicle then
        SetEntityCoords(cache.vehicle, destCoords)
    else
        SetEntityCoords(cache.ped, destCoords)
    end

    Wait(500)
    DoScreenFadeIn(1000)

    lib.notify({
        description = locale("MULTIVERSE_TRAVEL_TO", destPoint.Multiverse)
    })
end

SetupMarkers = function()
    DebugPrint("Setting Up Markers...")
    for index, verse in pairs(Config.Verse) do
        DebugPrint("Setting Up Marker:", index)

        local markerA_config = verse.PointA.Marker
        local markerB_config = verse.PointB.Marker

        local configMarkerA = markerA_config
        local configMarkerB = markerB_config

        configMarkerA.coords = verse.PointA.Position
        configMarkerB.coords = verse.PointB.Position

        local markerA = lib.marker.new(configMarkerA)
        local markerB = lib.marker.new(configMarkerB)

        local allow = verse.Allow

        local function nearby(self)

            if MyDimension() == self.point.Multiverse then
                self.marker:draw()
           
                if self.currentDistance < 2.5 then
                    local isPlayerInVehicle = cache.vehicle

                    if not lib.isTextUIOpen() then
                        lib.showTextUI(locale("INTERACT", self.destPoint.Multiverse))
                    end
                
                    if IsControlJustPressed(0, 51) then
                        if not allow.Vehicles and isPlayerInVehicle then
                            lib.notify({
                                description = locale("INTERACT_VEHICLE_ERROR")
                            })
                        else
                            OnInteract(self.destPoint, index)
                        end
                    end
                else
                    if lib.isTextUIOpen() then
                        lib.hideTextUI()
                    end
                end
            end
        end

        local pointA = lib.points.new({
            coords = verse.PointA.Position,
            distance = verse.PointA.DistanceView,
            destPoint = verse.PointB,
            point = verse.PointA,
            marker = markerA,
            nearby = nearby
        })

        local pointB = lib.points.new({
            coords = verse.PointB.Position,
            distance = verse.PointB.DistanceView,
            destPoint = verse.PointA,
            point = verse.PointB,
            marker = markerB,
            nearby = nearby
        })

        Multiverse[index] = {
            Markers = {
                MarkerA = markerA,
                MarkerB = markerB
            },
            Points = {
                PointA = pointA,
                PointB = pointB
            }
        }
    end
end

SetupMarkers()

TriggerServerEvent('abp:Multiverse:SetPlayerInWorld', nil, 0)