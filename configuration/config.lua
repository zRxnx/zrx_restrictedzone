Config = {}

Config.Command = 'restrictedzone'
Config.Keybind = 'F10'
Config.IconColor  = 'rgba(173, 216, 230, 1)'

Config.KPH = true
Config.Radius = {
    min = 50,
    max = 500,
}

Config.Menu = {
    type = 'context', --| context or menu
    postition = 'top-left' --| top-left, top-right, bottom-left or bottom-right
}

Config.Template = {
    ['Terror Attack'] = {
        jobs = {
            police = true,
        },

        blip = {
            sprite = 161,
            colour = { --| supports rgba and default gta colors
                r = 0,
                g = 0,
                b = 255,
                a = 255
            },
            scale = 0.5,
            alpha = 255,
            short = false,
            flash = true,
            flashTime = 400,
            displayText = 'Restrictedzone'
        },

        radiusBlip = {
            alpha = 140,
            colour = { --| supports rgba and default gta colors
                r = 0,
                g = 0,
                b = 255,
                a = 255
            },
            flash = true,
            flashTime = 400,
        },
    },
}

Config.Notify = function(player, msg, title, type, time)
    if IsDuplicityVersion() then
        TriggerClientEvent('ox_lib:notify', player, {
            title = title,
            description = msg,
            type = type,
            duration = time,
        })
    else
        lib.notify({
            title = title,
            description = msg,
            type = type,
            duration = time,
        })
    end
end

Config.Announce = function(player, msg, title, type, time)
    if IsDuplicityVersion() then
        TriggerClientEvent('ox_lib:notify', player, {
            title = title,
            description = msg,
            type = type,
            duration = time,
            position = 'top',
            showDuration = false,
            style = {
                backgroundColor = '#2E2E35',
                color = '#FFFFFF',
                fontSize = '22px',
                padding = '16px 24px',
                borderRadius = '8px',
                maxWidth = '1000px',
                width = 'auto',
                whiteSpace = 'pre-wrap',
                overflowWrap = 'break-word',
                wordBreak = 'break-word',
                ['.title'] = {
                    fontSize = '24px',
                },
                ['.description'] = {
                    fontSize = '20px',
                    color = '#DDDDDD',
                    lineHeight = '1.4',
                    whiteSpace = 'pre-wrap',
                    overflowWrap = 'break-word',
                    wordBreak = 'break-word',
                },
            },
            icon = 'fa-solid fa-info-circle',
            iconColor = '#3399FF',
        })
    else
        lib.notify({
            title = title,
            description = msg,
            type = type,
            duration = time,
            position = 'top',
            showDuration = false,
            style = {
                backgroundColor = '#2E2E35',
                color = '#FFFFFF',
                fontSize = '22px',
                padding = '16px 24px',
                borderRadius = '8px',
                maxWidth = '1000px',
                width = 'auto',
                whiteSpace = 'pre-wrap',
                overflowWrap = 'break-word',
                wordBreak = 'break-word',
                ['.title'] = {
                    fontSize = '24px',
                },
                ['.description'] = {
                    fontSize = '20px',
                    color = '#DDDDDD',
                    lineHeight = '1.4',
                    whiteSpace = 'pre-wrap',
                    overflowWrap = 'break-word',
                    wordBreak = 'break-word',
                },
            },
            icon = 'fa-solid fa-info-circle',
            iconColor = '#3399FF',
        })
    end
end