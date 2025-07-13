BREAK, VEHICLE, IS_WHITELIST, BLIP_DATA = {}, {}, {}, {}

RegisterKeyMapping(Config.Command, Strings.cmd_desc, 'keyboard', Config.Keybind)
RegisterCommand(Config.Command, function()
    OpenMainMenu()
end, false)
TriggerEvent('chat:addSuggestion', ('/%s'):format(Config.Command), Strings.cmd_desc, {})

RegisterNetEvent('zrx_restrictedzone:client:zone', function(action, data)
    if action == 'create' then
        CreateZone(data)
    elseif action == 'update' then
        UpdateZone(data)
    elseif action == 'remove' then
        RemoveZone(data)
    end
end)

RegisterNetEvent('onClientResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end

    if DoesEntityExist(VEHICLE[data.bId]) then
        SetVehicleMaxSpeed(VEHICLE[data.bId], 9999)
    end

    for bId, data in pairs(BLIP_DATA) do
        RemoveBlip(data.blip)
        RemoveBlip(data.radiusBlip)
    end
end)