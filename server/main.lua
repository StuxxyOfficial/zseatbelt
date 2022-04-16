RegisterServerEvent('seatbelt:server:PlaySound')
AddEventHandler('seatbelt:server:PlaySound', function(action, passengers)
    pass = json.decode(passengers)
    if Config.playSoundForPassengers and #pass > 0 then
        for _, ped in ipairs(pass) do
            local vol = (source == ped and Config.volume or Config.passengerVolume)
            TriggerClientEvent('seatbelt:client:PlaySound', ped, action, vol)
        end
    end
end)