local QBCore = exports['qb-core']:GetCoreObject()

-- VARS --

local PlayerData = QBCore.Functions.GetPlayerData()
local isPlyInChopping = false
local cancelChop = false

-- EVENTS --

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function(Player)
    PlayerData =  QBCore.Functions.GetPlayerData()
end)

function CheckForKeypress()

    CreateThread(function()

        while isPlyInChopping do

            Wait(0)

            if IsControlJustPressed(0, 38) then

                QBCore.Functions.TriggerCallback("qb-carchop:server:getCops", function(enoughCops)

                    if enoughCops >= Config.MinimumPolice then   
                                
                        local ply = PlayerPedId()
                        local vehicle = GetVehiclePedIsIn(ply, false)
                        local doorCount = GetNumberOfVehicleDoors(vehicle)

                        exports['qb-dispatch']:VehicleChoppingAlert()

                        for k = 0, doorCount, 1 do

                            QBCore.Functions.Progressbar("chop", "Chopping Part...", Config.ChoppingTime, false, true, {
                                disableMovement = true,
                                disableCarMovement = true,
                                disableMouse = false,
                                disableCombat = true
                                }, {}, {}, {}, function()
                                    SetVehicleDoorOpen(vehicle, k, false, false)
                                    Wait(700)
                                    SetVehicleDoorBroken(vehicle, k, true)

                                    if k == doorCount then

                                        for key, value in pairs(Config.RewardItems) do

                                            local randNum = math.floor(math.random(0, 100))
                                            local randAmount = math.floor(math.random(value.min, value.max))
                                            
                                            if randNum <= value.percent then
                                                TriggerServerEvent('QBCore:Server:AddItem', key, randAmount)
                                                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items[key], 'add')
                                            end

                                        end

                                        DeleteEntity(vehicle)
                                        cancelChop = false
                                    end
                                end, function()
                                    cancelChop = true
                            end)

                            if cancelChop then break end

                            Wait(Config.ChoppingTime * 2)

                        end

                    else

                        TriggerEvent('QBCore:Notify', "Not enough cops around for that.", "error", 2000)

                    end

                end)

            end

        end

    end)

end

Citizen.CreateThread(function()

    for k, v in pairs(Config.ChoppingLocations) do

        local chopSpot = BoxZone:Create(Config.ChoppingLocations[k].coords, 10, 10, {
            name = "carchop",
            heading = Config.ChoppingLocations[k].rotation,
            debugPoly = Config.ChoppingLocations[k].debug,
            minZ = 29.17,
            maxZ = 32.57
        })

        chopSpot:onPlayerInOut(function(isPointInside, point)
            if isPointInside then
                local ply = PlayerPedId()

                if IsPedInAnyVehicle(ply, true) and GetPedInVehicleSeat(GetVehiclePedIsIn(ply), -1) == ply then
                    exports['qb-core']:DrawText("[E] To Chop Your Vehicle", 'left')
                    
                    isPlyInChopping = true
                    CheckForKeypress()
                end
            else
                exports['qb-core']:HideText()
                isPlyInChopping = false
            end
        end)

    end

end)