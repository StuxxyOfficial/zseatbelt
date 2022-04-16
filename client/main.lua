SetFlyThroughWindscreenParams(Config.ejectVelocity, Config.unknownEjectVelocity, Config.unknownModifier, Config.minDamage);
local seatbeltOn = false
local uiactive = false
local playerPed = PlayerPedId()

CreateThread(function()
    while true do
        playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed) then
            if seatbeltOn then
                if Config.fixedWhileBuckled then
                    DisableControlAction(0, 75, true) -- Disable exit vehicle when stop
                    DisableControlAction(27, 75, true) -- Disable exit vehicle when Driving
                end
                toggleUI(false)
            else
                toggleUI(true)
				local veh = GetVehiclePedIsIn(playerPed,false)
                local class = GetVehicleClass(veh)
                if LocalPlayer.state.handcuffed == true then return end
                if LocalPlayer.state.ziptied == true then return end

                if class ~= 8 and class ~= 13 and class ~= 14 and not IsPedDeadOrDying(playerPed) then
                    local speed = GetEntitySpeed(veh)
                    if (speed * 2.236936) > 30 then
                    playBeltAlarm("seatbelt")
                    Citizen.Wait(1500)
                    else
                    Citizen.Wait(500)
                    end
                end
            end
        else
            if seatbeltOn then
                seatbeltOn = false
                toggleSeatbelt(false, false)
            end
            toggleUI(false)
            Wait(1000)
        end
        Wait(5)
    end
end)

function toggleSeatbelt(makeSound, toggle)
    if toggle == nil then
        if seatbeltOn then
            playSound("unbuckle")
            SetFlyThroughWindscreenParams(Config.ejectVelocity, Config.unknownEjectVelocity, Config.unknownModifier, Config.minDamage)
        else
            playSound("buckle")
            SetFlyThroughWindscreenParams(10000.0, 10000.0, 17.0, 500.0);
        end
        seatbeltOn = not seatbeltOn
    else
        if toggle then
            playSound("buckle")
            SetFlyThroughWindscreenParams(10000.0, 10000.0, 17.0, 500.0);
        else
            playSound("unbuckle")
            SetFlyThroughWindscreenParams(Config.ejectVelocity, Config.unknownEjectVelocity, Config.unknownModifier, Config.minDamage)
        end
        seatbeltOn = toggle
    end
end

function toggleUI(status)
    if Config.showUnbuckledIndicator then
        if uiactive ~= status then
            uiactive = status
            if status then
                SendNUIMessage({type = "showindicator"})
            else
                SendNUIMessage({type = "hideindicator"})
            end
        end
    end
end

function playSound(action)
    if Config.playSound then
        if Config.playSoundForPassengers then
            local veh = GetVehiclePedIsUsing(playerPed)
            local maxpeds = GetVehicleMaxNumberOfPassengers(veh) - 2
            local passengers = {}
            for i = -1, maxpeds do
                if not IsVehicleSeatFree(veh, i) then
                    local ped = GetPlayerServerId(NetworkGetPlayerIndexFromPed(GetPedInVehicleSeat(veh, i)) )
                    table.insert(passengers, ped)
                end
            end
            TriggerServerEvent('seatbelt:server:PlaySound', action, json.encode(passengers))
        else
            SendNUIMessage({type = action, volume = Config.volume})
        end
    end
end

function playBeltAlarm(action)
    if Config.playSound then
        SendNUIMessage({type = action, volume = Config.volume})
    end
end

RegisterCommand('toggleseatbelt', function(source, args, rawCommand)
    if IsPedInAnyVehicle(playerPed, false) then
        local class = GetVehicleClass(GetVehiclePedIsIn(playerPed))
        if class ~= 8 and class ~= 13 and class ~= 14 then
            toggleSeatbelt(true)
        end
    end
end, false)

RegisterNetEvent('seatbelt:client:PlaySound')
AddEventHandler('seatbelt:client:PlaySound', function(action, volume)
    SendNUIMessage({type = action, volume = volume})
end)

exports("status", function() return seatbeltOn end)

RegisterKeyMapping('toggleseatbelt', 'Toggle Seatbelt', 'keyboard', 'B')
