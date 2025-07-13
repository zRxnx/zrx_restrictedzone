BLIP_DATA = {}

RegisterNetEvent('esx:playerLoaded', function(player, xPlayer, isNew)
    Wait(1000)

    for bId, data in pairs(BLIP_DATA) do
        TriggerClientEvent('zrx_restrictedzone:client:zone', player, 'create', data)
    end
end)

CreateThread(function()
    lib.versionCheck('zrxnx/zrx_restrictedzone')
end)

RegisterNetEvent('zrx_restrictedzone:server:zone', function(action, data)
    local xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(source)
    local cfg = Config.Template[data.index]

    if not cfg.jobs[xPlayer.job.name] then
        return
    end

    local bId

    if action == 'create' then
        bId = #BLIP_DATA + 1

        BLIP_DATA[bId] = {}

        BLIP_DATA[bId].creator = {
            id = xPlayer.source,
            name = xPlayer.name,
            job = xPlayer.job.label,
            grade = xPlayer.job.grade,
            identifier = xPlayer.identifier,
        }

        BLIP_DATA[bId].jobs = cfg.jobs
        BLIP_DATA[bId].coords = data.coords
        BLIP_DATA[bId].index = data.index
        BLIP_DATA[bId].street = data.street
        
        BLIP_DATA[bId].radius = data.radius
        BLIP_DATA[bId].text = data.text

        BLIP_DATA[bId].timeout = data.timeout
        BLIP_DATA[bId].speedlimit = data.speedlimit
        BLIP_DATA[bId].displayText = data.displayText

        BLIP_DATA[bId].bId = bId

        if data.timeout then
            BLIP_DATA[bId].timeout.curTime = data.timeout.time
        end

        lib.logger(xPlayer.source, 'zrx_restrictedzone:createZone', 'Created a zone ' .. data.radius)

        TriggerClientEvent('zrx_restrictedzone:client:zone', -1, 'create', BLIP_DATA[bId])
    elseif action == 'update' then
        bId = data.bId

        BLIP_DATA[bId].radius = data.radius
        BLIP_DATA[bId].update = data.update

        lib.logger(xPlayer.source, 'zrx_restrictedzone:updateZone', 'Updated a zone ' .. data.radius)

        TriggerClientEvent('zrx_restrictedzone:client:zone', -1, 'update', BLIP_DATA[bId])
    elseif action == 'remove' then
        bId = data.bId

        BLIP_DATA[bId].textEnd = data.textEnd

        lib.logger(xPlayer.source, 'zrx_restrictedzone:removeZone', 'Removed a zone ' .. data.radius)

        TriggerClientEvent('zrx_restrictedzone:client:zone', -1, 'remove', BLIP_DATA[bId])

        BLIP_DATA[bId] = nil
    end
end)

CreateThread(function()
    while true do
        for bId, data in pairs(BLIP_DATA) do
            if not data.timeout then goto continue end

            if data.timeout.curTime > 0 then
                BLIP_DATA[bId].timeout.curTime -= 1
            elseif data.timeout.curTime <= 0 then
                BLIP_DATA[bId].textEnd = data.timeout.text

                TriggerClientEvent('zrx_restrictedzone:client:zone', -1, 'remove', BLIP_DATA[bId])

                BLIP_DATA[bId] = nil
            end

            ::continue::
        end

        Wait(60000)
    end
end)

lib.callback.register('zrx_restrictedzone:server:isAllowed', function(player)
    local xPlayer = ZRX_UTIL.fwObj.GetPlayerFromId(player)

    for i, data in pairs(Config.Template) do
        if data.jobs[xPlayer.job.name] then
            return true
        end
    end

    return false
end)