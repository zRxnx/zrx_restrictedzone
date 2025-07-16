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

    for bId, data in pairs(BLIP_DATA) do
        RemoveBlip(data.blip)
        RemoveBlip(data.radiusBlip)

        if DoesEntityExist(VEHICLE[bId]) then
            SetVehicleMaxSpeed(VEHICLE[bId], 9999)
        end
    end
end)

CreateThread(function()
    local popType, vehCoords

    while true do
        for bId, data in pairs(BLIP_DATA) do
            if not data.removeCars then
                goto continue
            end

            for i, data2 in pairs(GetGamePool('CVehicle')) do
                vehCoords = GetEntityCoords(data2)
                popType = GetEntityPopulationType(data2)

                --| GetPedInVehicleSeat(data2, -1) ~= 0 and not IsPedAPlayer(GetPedInVehicleSeat(data2, -1)) | I think pop type is a better check
                if #(vector3(vehCoords.x, vehCoords.y, vehCoords.z) - vector3(data.coords.x, data.coords.y, data.coords.z)) <= data.radius + 30 and
                (popType == 2 or popType == 3 or popType == 4 or popType == 5) then
                    SetEntityAsMissionEntity(data2, true, true)
                    DeleteVehicle(data2)
                end
            end

            ::continue::
        end

        Wait(2000)
    end
end)