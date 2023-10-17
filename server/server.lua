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

    if type(cindex) ~= 'number' or type(data[1]) ~= 'string' or type(data[2]) ~= 'string' or type(data[3]) ~= 'number' or
    type(data[4]) ~= 'number' or type(data[5]) ~= 'number' or type(data[6]) ~= 'boolean' or type(data[7]) ~= 'boolean' or
    type(data[8]) ~= 'boolean' or type(data[9]) ~= 'boolean' or type(coords) ~= 'vector3' or type(street) ~= 'string' or
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
        ]]):format(street, data[3], #BLIP_DATA, cindex, BLIP_DATA[#BLIP_DATA].textStart, BLIP_DATA[#BLIP_DATA].textEnd,
        BLIP_DATA[#BLIP_DATA].speedlimit, BLIP_DATA[#BLIP_DATA].timeout, BLIP_DATA[#BLIP_DATA].removeCars, BLIP_DATA[#BLIP_DATA].playSound)

        CORE.Server.DiscordLog(xPlayer.player, 'START ZONE', message, Webhook.Links.startBlip)
    end

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        CORE.Bridge.notification(player, data[1])
        TriggerClientEvent('zrx_restrictedzone:client:startBlip', player, BLIP_DATA[#BLIP_DATA])
    end
end)

RegisterNetEvent('zrx_restrictedzone:server:editSyncBlip', function(data, index)
    local xPlayer = CORE.Bridge.getVariables(source)
    local temp = Config.Templates[BLIP_DATA[index].cindex]

    if type(index) ~= 'number' or type(data[1]) ~= 'string' or type(data[2]) ~= 'string' or type(data[3]) ~= 'number' or type(data[4]) ~= 'number' or
    type(data[5]) ~= 'number' or type(data[6]) ~= 'boolean' or type(data[7]) ~= 'boolean' or type(data[8]) ~= 'boolean' or type(data[9]) ~= 'boolean' or
    not temp.allowedJobs[xPlayer.job.name] then
        return Config.PunishPlayer(xPlayer.player, 'Tried to trigger "zrx_restrictedzone:server:editSyncBlip"')
    end

    if Player.HasCooldown(xPlayer.player) then
        return CORE.Bridge.notification(xPlayer.player, Strings.cooldown)
    end

    BLIP_DATA[index].textUpdate = data[1]
    BLIP_DATA[index].textEnd = data[2]
    BLIP_DATA[index].radius = data[3]
    BLIP_DATA[index].speedlimit = data[8] == true and data[4] or false
    BLIP_DATA[index].timeout = data[9] == true and data[5] or false
    BLIP_DATA[index].curTime = data[5] * 60
    BLIP_DATA[index].playSound = data[7]
    BLIP_DATA[index].removeCars = data[6]

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
        ]]):format(BLIP_DATA[index].radius, index, BLIP_DATA[index].cindex, BLIP_DATA[index].textStart, BLIP_DATA[index].textEnd,
        BLIP_DATA[index].speedlimit, BLIP_DATA[index].timeout, BLIP_DATA[index].removeCars, BLIP_DATA[index].playSound)

        CORE.Server.DiscordLog(xPlayer.player, 'EDIT ZONE', message, Webhook.Links.editBlip)
    end

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        CORE.Bridge.notification(player, data[1])
        TriggerClientEvent('zrx_restrictedzone:client:editBlip', player, BLIP_DATA[index], index)
    end
end)

RegisterNetEvent('zrx_restrictedzone:server:removeSyncBlip', function(data, index)
    local xPlayer = CORE.Bridge.getVariables(source)

    if type(index) ~= 'number' or type(data[1]) ~= 'string' or not BLIP_DATA[index].allowedJobs[xPlayer.job.name] then
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
        ]]):format(BLIP_DATA[index].street, BLIP_DATA[index].radius, index, BLIP_DATA[index].cindex)

        CORE.Server.DiscordLog(xPlayer.player, 'REMOVE ZONE', message, Webhook.Links.removeBlip)
    end

    for i, player in pairs(GetPlayers()) do
        player = tonumber(player)
        CORE.Bridge.notification(player, data[1])
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