COOLDOWN, PLAYER_CACHE, BLIP_DATA = {}, {}, {}
CORE = exports.zrx_utility:GetUtility()
local GetPlayers = GetPlayers
local TriggerClientEvent = TriggerClientEvent

RegisterNetEvent('zrx_utility:bridge:playerLoaded', function(player)
    PLAYER_CACHE[player] = CORE.Server.GetPlayerCache(player)

    for i, data in pairs(BLIP_DATA) do
        CORE.Bridge.notification(player, data.textStart)
        TriggerClientEvent('zrx_restrictedzone:client:startBlip', player, data)
    end
end)

CreateThread(function()
    if Config.CheckForUpdates then
        CORE.Server.CheckVersion('zrx_restrictedzone')
    end

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        PLAYER_CACHE[player] = CORE.Server.GetPlayerCache(player)
    end
end)

RegisterNetEvent('zrx_restrictedzone:server:startSyncBlip', function(data, cindex, coords, street)
    local xPlayer = CORE.Bridge.getVariables(source)
    local temp = Config.Templates[cindex]

    if type(cindex) ~= 'number' or type(data.textStart) ~= 'string' or type(data.textEnd) ~= 'string' or type(data.radius) ~= 'number' or
    (type(data.speedlimit) ~= 'boolean' and type(data.speedlimit) ~= 'number') or (type(data.timeout) ~= 'boolean' and type(data.timeout) ~= 'number') or
    type(data.removeCars) ~= 'boolean' or type(data.playSound) ~= 'boolean' or type(coords) ~= 'vector3' or type(street) ~= 'string' or
    not temp.allowedJobs[xPlayer.job.name] then
        return Config.PunishPlayer(xPlayer.player, 'Tried to trigger "zrx_restrictedzone:server:startSyncBlip"')
    end

    if Player.HasCooldown(xPlayer.player) then
        return CORE.Bridge.notification(xPlayer.player, Strings.cooldown)
    end

    BLIP_DATA[#BLIP_DATA + 1] = {
        creator = {
            identifier = xPlayer.identifier,
            name = xPlayer.name,
            job = xPlayer.job.label,
            grade = xPlayer.job.grade,
            grade_label = xPlayer.job.grade_label,
            svid = xPlayer.player
        },
        allowedJobs = temp.allowedJobs,
        coords = coords,
        cindex = cindex,
        textStart = data.textStart,
        textEnd = data.textEnd,
        radius = data.radius,
        speedlimit = data.speedlimit,
        timeout = data.timeout,
        curTime = type(data.timeout) == 'number' and data.timeout * 60,
        removeCars = data.removeCars,
        playSound = data.playSound,
        street = street,
    }

    if Webhook.Links.startBlip:len() > 0 then
        local message = ([[
            The player started a restricted zone

            Street: **%s**
            Radius: **%s**
            Blip Index: **%s**
            Config Index: **%s**
            Text Start: **%s**
            Text End: : **%s**
            Speedlimit: **%s**
            Timeout: **%s**
            Remove NPC Cars: **%s**
            Playsound: **%s**
        ]]):format(street, data.radius, #BLIP_DATA, cindex, data.textStart, data.textEnd,
        data.speedlimit, data.timeout, data.removeCars, data.playSound)

        CORE.Server.DiscordLog(xPlayer.player, 'START ZONE', message, Webhook.Links.startBlip)
    end

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        CORE.Bridge.notification(player, data.textStart)
        TriggerClientEvent('zrx_restrictedzone:client:startBlip', player, BLIP_DATA[#BLIP_DATA])
    end
end)

RegisterNetEvent('zrx_restrictedzone:server:editSyncBlip', function(data, index)
    local xPlayer = CORE.Bridge.getVariables(source)
    local temp = Config.Templates[BLIP_DATA[index].cindex]

    if type(index) ~= 'number' or type(data.textUpdate) ~= 'string' or type(data.textEnd) ~= 'string' or type(data.radius) ~= 'number' or
    (type(data.speedlimit) ~= 'boolean' and type(data.speedlimit) ~= 'number') or (type(data.timeout) ~= 'boolean' and type(data.timeout) ~= 'number') or
    type(data.removeCars) ~= 'boolean' or type(data.playSound) ~= 'boolean' or not temp.allowedJobs[xPlayer.job.name] then
        return Config.PunishPlayer(xPlayer.player, 'Tried to trigger "zrx_restrictedzone:server:startSyncBlip"')
    end

    if Player.HasCooldown(xPlayer.player) then
        return CORE.Bridge.notification(xPlayer.player, Strings.cooldown)
    end

    BLIP_DATA[index].textUpdate = data.textUpdate
    BLIP_DATA[index].textEnd = data.textEnd
    BLIP_DATA[index].radius = data.radius
    BLIP_DATA[index].speedlimit = data.speedlimit
    BLIP_DATA[index].timeout = data.timeout
    BLIP_DATA[index].curTime = type(data.timeout) == 'number' and data.timeout * 60
    BLIP_DATA[index].playSound = data.playSound
    BLIP_DATA[index].removeCars = data.removeCars

    if Webhook.Links.editBlip:len() > 0 then
        local message = ([[
            The player edited a restricted zone

            Radius: **%s**
            Blip Index: **%s**
            Config Index: **%s**
            Text Start: **%s**
            Text End: : **%s**
            Speedlimit: **%s**
            Timeout: **%s**
            Remove NPC Cars: **%s**
            Playsound: **%s**
        ]]):format(data.radius, index, BLIP_DATA[index].cindex, BLIP_DATA[index].textStart, data.textEnd,
        data.speedlimit, data.timeout, data.removeCars, data.playSound)

        CORE.Server.DiscordLog(xPlayer.player, 'EDIT ZONE', message, Webhook.Links.editBlip)
    end

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        CORE.Bridge.notification(player, data.textUpdate)
        TriggerClientEvent('zrx_restrictedzone:client:editBlip', player, BLIP_DATA[index], index)
    end
end)

RegisterNetEvent('zrx_restrictedzone:server:removeSyncBlip', function(data, index)
    local xPlayer = CORE.Bridge.getVariables(source)

    if type(index) ~= 'number' or type(data.textEnd) ~= 'string' or not BLIP_DATA[index].allowedJobs[xPlayer.job.name] then
        return Config.PunishPlayer(xPlayer.player, 'Tried to trigger "zrx_restrictedzone:server:removeSyncBlip"')
    end

    if Player.HasCooldown(xPlayer.player) then
        return CORE.Bridge.notification(xPlayer.player, Strings.cooldown)
    end

    if Webhook.Links.removeBlip:len() > 0 then
        local message = ([[
            The player removed a restricted zone

            Street: **%s**
            Radius: **%s**
            Blip Index: **%s**
            Config Index: **%s**
            Text End: **%s**
        ]]):format(BLIP_DATA[index].street, BLIP_DATA[index].radius, index, BLIP_DATA[index].cindex, data.textEnd)

        CORE.Server.DiscordLog(xPlayer.player, 'REMOVE ZONE', message, Webhook.Links.removeBlip)
    end

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        CORE.Bridge.notification(player, data.textEnd)
        TriggerClientEvent('zrx_restrictedzone:client:removeBlip', player, index)
    end

    BLIP_DATA[index] = nil
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
                    CORE.Bridge.notification(player, data.textEnd)
                    TriggerClientEvent('zrx_restrictedzone:client:removeBlip', player, i)
                end

                if Webhook.Links.removeBlip:len() > 0 then
                    local message = ([[
                        The player removed a restricted zone due to timeout
            
                        Street: **%s**
                        Radius: **%s**
                        Blip Index: **%s**
                        Config Index: **%s**
                    ]]):format(data.street, data.radius, data.timeout, i, data.index)

                    CORE.Server.DiscordLog(BLIP_DATA[i].creator.svid, 'TIMEOUT REMOVE BLIP', message, Webhook.Links.removeBlip)
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
    return not not COOLDOWN[PLAYER_CACHE[player].license]
end)