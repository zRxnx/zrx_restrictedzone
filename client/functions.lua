CreateZone = function(data)
    BLIP_DATA[data.bId] = data

    local cfg = Config.Template[data.index]

    PlaySoundFrontend(-1, 'BASE_JUMP_PASSED', 'HUD_AWARDS', false)

    BLIP_DATA[data.bId].zone = lib.zones.sphere({
        coords = data.coords,
        radius = data.radius,
        inside = function()
            print('inside')
            BREAK[data.bId] = false
            VEHICLE[data.bId] = cache.vehicle

            while not BREAK[data.bId] do
                if not DoesEntityExist(VEHICLE[data.bId]) then
                    goto continue
                end

                if IsVehicleSirenOn(VEHICLE[data.bId]) then
                    IS_WHITELIST[data.bId] = true
                elseif not IsVehicleSirenOn(VEHICLE[data.bId]) then
                    IS_WHITELIST[data.bId] = false
                end

                if not IS_WHITELIST[data.bId] then
                    SetVehicleMaxSpeed(VEHICLE[data.bId], Config.KPH and data.speedlimit.speed / 3.6 or data.speedlimit.speed / 2.236936)
                else
                    SetVehicleMaxSpeed(VEHICLE[data.bId], 9999)
                end

                if VEHICLE[data.bId] ~= cache.vehicle then
                    if not DoesEntityExist(VEHICLE[data.bId]) then
                        goto continue
                    end

                    SetVehicleMaxSpeed(VEHICLE[data.bId], 9999)

                    VEHICLE[data.bId] = cache.vehicle
                end

                ::continue::
                Wait(500)
            end
        end,
        onExit = function()
            print('onExit')
            BREAK[data.bId] = true
            IS_WHITELIST[data.bId] = false

            if not DoesEntityExist(VEHICLE[data.bId]) then
                return
            end

            SetVehicleMaxSpeed(VEHICLE[data.bId], 9999)
        end,
        onEnter = function()
            print('onEnter')
        end
    })

    local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
    local color = ('0x%02X%02X%02X%02X'):format(cfg.blip.colour.r, cfg.blip.colour.g, cfg.blip.colour.b, cfg.blip.colour.a)

    SetBlipSprite(blip, cfg.blip.sprite)
    SetBlipColour(blip, tonumber(color))
    SetBlipScale(blip, cfg.blip.scale)
    SetBlipAlpha(blip, cfg.blip.alpha)
    SetBlipAsShortRange(blip, cfg.blip.short)
    SetBlipFlashes(blip, cfg.blip.flash)
    SetBlipFlashInterval(blip, cfg.blip.flashTime)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(data.displayText)
    EndTextCommandSetBlipName(blip)

    local radiusBlip = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, data.radius)
    color = ('0x%02X%02X%02X%02X'):format(cfg.radiusBlip.colour.r, cfg.radiusBlip.colour.g, cfg.radiusBlip.colour.b, cfg.radiusBlip.colour.a)

    SetBlipAlpha(radiusBlip, cfg.radiusBlip.alpha)
    SetBlipColour(radiusBlip, tonumber(color))
    SetBlipFlashes(radiusBlip, cfg.radiusBlip.flash)
    SetBlipFlashInterval(radiusBlip, cfg.radiusBlip.flashTime)

    BLIP_DATA[data.bId].blip = blip
    BLIP_DATA[data.bId].radiusBlip = radiusBlip

    Config.Announce(nil, data.text, Strings.title_announce:format(data.creator.job), 'inform', 8000)
end

UpdateZone = function(data)
    BLIP_DATA[data.bId].radius = data.radius
    local cfg = Config.Template[data.index]

    PlaySoundFrontend(-1, 'BASE_JUMP_PASSED', 'HUD_AWARDS', false)

    RemoveBlip(BLIP_DATA[data.bId].radiusBlip)

    local radiusBlip = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, data.radius)

    SetBlipAlpha(radiusBlip, 140)
    SetBlipColour(radiusBlip, cfg.blip.colour)

    BLIP_DATA[data.bId].radiusBlip = radiusBlip

    print(json.encode(data, {indent = true}))

    Config.Announce(nil, data.update, Strings.title_announce:format(data.creator.job), 'inform', 8000)
end

RemoveZone = function(data)
    BLIP_DATA[data.bId].zone:remove()

    PlaySoundFrontend(-1, 'PEYOTE_COMPLETED', 'HUD_AWARDS', false)

    RemoveBlip(BLIP_DATA[data.bId].blip)
    RemoveBlip(BLIP_DATA[data.bId].radiusBlip)

    if DoesEntityExist(VEHICLE[data.bId]) then
        SetVehicleMaxSpeed(VEHICLE[data.bId], 9999)
    end

    Config.Announce(nil, data.textEnd, Strings.title_announce:format(data.creator.job), 'inform', 8000)
    BLIP_DATA[data.bId] = nil
end