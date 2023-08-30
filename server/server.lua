ESX, COOLDOWN, PLAYER_CACHE, BLIP_DATA = Config.EsxImport(), {}, {}, {}

RegisterNetEvent('esx:playerLoaded', function(player)
    PLAYER_CACHE[player] = GetPlayerData(player)

    for i, data in pairs(BLIP_DATA) do
        Config.Notification(player, data.textStart)
        TriggerClientEvent('zrx_restrictedzone:client:startBlip', player, data)
    end
end)

CreateThread(function()
    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        PLAYER_CACHE[player] = GetPlayerData(player)
    end
end)

RegisterNetEvent('zrx_restrictedzone:server:startSyncBlip', function(data, index, coords, street)
    local xPlayer = ESX.GetPlayerFromId(source)
    local temp = Config.Templates[index]

    if type(index) ~= 'number' or type(data[1]) ~= 'string' or type(data[2]) ~= 'string' or type(data[3]) ~= 'number' or
    type(data[4]) ~= 'number' or type(data[5]) ~= 'number' or type(data[6]) ~= 'boolean' or type(data[7]) ~= 'boolean' or
    type(data[8]) ~= 'boolean' or type(data[9]) ~= 'boolean' or type(coords) ~= 'vector3' or type(street) ~= 'string' or
    not temp.allowedJobs[xPlayer.job.name] then
        return Config.PunishPlayer(xPlayer.source, 'Tried to trigger "zrx_restrictedzone:server:startSyncBlip"')
    end

    if HasCooldown(xPlayer.source) then
        return Config.Notification(xPlayer.source, 'On cooldown')
    end

    BLIP_DATA[#BLIP_DATA + 1] = {
        creator = {
            identifier = xPlayer.identifier,
            name = xPlayer.getName(),
            job = xPlayer.job.label,
            grade = xPlayer.job.grade,
            grade_label = xPlayer.job.grade_label,
            svid = xPlayer.source
        },
        allowedJobs = temp.allowedJobs,
        coords = coords,
        index = index,
        textStart = data[1],
        textEnd = data[2],
        radius = data[3],
        speedlimit = data[8] == true and data[4] or false,
        timeout = data[9] == true and data[5] or false,
        curTime = data[5] * 60,
        removeCars = data[6],
        playSound = data[7],
        street = street,
    }

    if Webhook.Settings.startBlip then
        DiscordLog(xPlayer.source, 'START BLIP', ('Started a blip at %s street with a %s radius. BIP: %s - CID: %s'):format(street, data[3], #BLIP_DATA, index), 'startBlip')
    end

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        Config.Notification(player, data[1])
        TriggerClientEvent('zrx_restrictedzone:client:startBlip', player, BLIP_DATA[#BLIP_DATA])
    end
end)

RegisterNetEvent('zrx_restrictedzone:server:removeSyncBlip', function(data, id)
    id = id.id
    local xPlayer = ESX.GetPlayerFromId(source)

    if type(id) ~= 'number' or type(data[1]) ~= 'string' or not BLIP_DATA[id].allowedJobs[xPlayer.job.name] then
        return Config.PunishPlayer(xPlayer.source, 'Tried to trigger "zrx_restrictedzone:server:removeSyncBlip"')
    end

    if HasCooldown(xPlayer.source) then
        return Config.Notification(xPlayer.source, 'On cooldown')
    end

    if Webhook.Settings.removeBlip then
        DiscordLog(xPlayer.source, 'REMOVE BLIP', ('Removed a blip at %s street with a %s radius. BIP: %s - CID: %s'):format(BLIP_DATA[id].street, BLIP_DATA[id].radius, id, BLIP_DATA[id].index), 'removeBlip')
    end

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        Config.Notification(player, data[1])
        TriggerClientEvent('zrx_restrictedzone:client:removeBlip', player, id)
    end

    BLIP_DATA[id] = nil
end)

CreateThread(function()
    while true do
        for i, data in pairs(BLIP_DATA) do
            if not data.timeout then goto continue end

            if data.curTime > 0 then
                BLIP_DATA[i].curTime -= 1
            elseif data.curTime == 0 then
                for k, player in pairs(GetPlayers()) do
                    player = tonumber(player)
                    Config.Notification(player, data.textEnd)
                    TriggerClientEvent('zrx_restrictedzone:client:removeBlip', player, i)
                end

                if Webhook.Settings.removeBlip then
                    DiscordLog(BLIP_DATA[i].creator.svid, 'REMOVE BLIP', ('Removed a blip at %s street with a %s radius due to %s timeout. BIP: %s - CID: %s'):format(data.street, data.radius, data.timeout, i, data.index), 'removeBlip')
                end

                BLIP_DATA[i] = nil
            end

            ::continue::
        end

        Wait(1000)
    end
end)

exports('activeBlips', function()
    return BLIP_DATA
end)

exports('hasCooldown', function(player)
    return not not COOLDOWN[player]
end)