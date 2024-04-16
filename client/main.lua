local Multiverse = {}
local timeout = 0

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
    for index, verse in pairs(Config.Verse) do

        local markerA_config = verse.PointA.Marker
        local markerB_config = verse.PointB.Marker

        local markerA = lib.marker.new({
            type = markerA_config.Type,
            coords = verse.PointA.Position,
            color = markerA_config.Color,
        })

        local markerB = lib.marker.new({
            type = markerB_config.Type,
            coords = verse.PointB.Position,
            color = markerB_config.Color,
        })

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