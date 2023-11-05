local GetEntityCoords = GetEntityCoords
local DrawSphere = DrawSphere
local GetStreetNameFromHashKey = GetStreetNameFromHashKey
local GetStreetNameAtCoord = GetStreetNameAtCoord

OpenMainMenu = function()
    if not Config.CanOpenMenu() then return end

    local MENU = {}
    local isAllowed = false

    for i, data in pairs(Config.Templates) do
        if data.allowedJobs[CORE.Bridge.getVariables().job.name] then
            isAllowed = true
            break
        end
    end

    if not isAllowed then
        return CORE.Bridge.notification(Strings.no_perms)
    end

    MENU[#MENU + 1] = {
        title = Strings.zone_create,
        description = Strings.zone_create_desc,
        arrow = #Config.Templates > 0 and not COOLDOWN,
        disabled = #Config.Templates <= 0 or COOLDOWN,
        icon = 'fa-solid fa-plus',
        iconColor = Config.IconColor,
        onSelect = function()
            OpenCreateMenu()
        end
    }

    MENU[#MENU + 1] = {
        title = Strings.zone_edit,
        description = Strings.zone_edit_desc,
        arrow = #BLIP_DATA > 0 and not COOLDOWN,
        disabled = #BLIP_DATA <= 0 or COOLDOWN,
        icon = 'fa-solid fa-pen-to-square',
        iconColor = Config.IconColor,
        onSelect = function()
            OpenEditMenu()
        end
    }

    MENU[#MENU + 1] = {
        title = Strings.zone_remove,
        description = Strings.zone_remove_desc,
        arrow = #BLIP_DATA > 0 and not COOLDOWN,
        disabled = #BLIP_DATA <= 0 or COOLDOWN,
        icon = 'fa-solid fa-trash',
        iconColor = Config.IconColor,
        onSelect = function()
            OpenRemoveMenu()
        end
    }

    CORE.Client.CreateMenu({
        id = 'zrx_restrictedzone:zone:main',
        title = Strings.title,
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenCreateMenu = function()
    local MENU = {}
    local coords = GetEntityCoords(cache.ped)
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    local job = CORE.Bridge.getVariables().job

    StartCooldown()

    for k, data in pairs(Config.Templates) do
        MENU[#MENU + 1] = {
            title = (Strings.create_click):format(data.name),
            description = Strings.create_click_desc,
            arrow = data.allowedJobs[job.name],
            disabled = not data.allowedJobs[job.name],
            icon = 'fa-solid fa-plus',
            iconColor = Config.IconColor,
            args = {
                cid = k
            },
            onSelect = function(args)
                local input = lib.inputDialog(Strings.title, {
                    {
                        type = 'textarea',
                        label = Strings.i_start_notify,
                        description = Strings.i_start_notify_desc,
                        required = true,
                        default = (Strings.i_start_notify_default):format(street, job.label:upper()),
                        min = 3,
                        max = 200
                    },
                    {
                        type = 'textarea',
                        label = Strings.i_end_notify,
                        description = Strings.i_end_notify_desc,
                        required = true,
                        default = (Strings.i_end_notify_default):format(street, job.label:upper()),
                        min = 3,
                        max = 200
                    },
                    {
                        type = 'checkbox',
                        label = Strings.i_use_playsound,
                        checked = true
                    },
                    {
                        type = 'number',
                        label = Strings.i_radius,
                        description = Strings.i_radius_desc,
                        required = true,
                        default = 50,
                        min = 10,
                        max = 200
                    },
                    {
                        type = 'checkbox',
                        label = Strings.i_use_removecars,
                        checked = true
                    },
                    {
                        type = 'number',
                        label = Strings.i_speedlimit,
                        description = Strings.i_speedlimit_desc,
                        required = true,
                        default = 50
                    },
                    {
                        type = 'checkbox',
                        label = Strings.i_use_speedlimit,
                        checked = true
                    },
                    {
                        type = 'number',
                        label = Strings.i_timeout,
                        description = Strings.i_timeout_desc,
                        required = true,
                        default = 10,
                        max = 60
                    },
                    {
                        type = 'checkbox',
                        label = Strings.i_use_timeout,
                        checked = true
                    },
                })

                if not input then
                    CORE.Bridge.notification(Strings.not_fill)
                    return OpenCreateMenu()
                end

                local DATA = {
                    textStart = input[1],
                    textEnd = input[2],
                    playSound = input[3],
                    radius = input[4],
                    removeCars = input[5],
                    speedlimit = input[7] == true and input[6],
                    timeout = input[9] == true and input[8],
                }

                TriggerServerEvent('zrx_restrictedzone:server:startSyncBlip', DATA, args.cid, coords, street)

                CreateThread(function()
                    local timeout, alpha = 0, 0.5
                    local r, g, b = Config.IconColor:match('rgba%((%d+),%s*(%d+),%s*(%d+)')
                    r, g, b = tonumber(r), tonumber(g), tonumber(b)

                    while timeout <= 500 do
                        timeout += 1
                        alpha -= 0.001
                        DrawSphere(coords.x, coords.y, coords.z, input[3], r, g, b, alpha)
                        Wait()
                    end
                end)
            end
        }
    end

    CORE.Client.CreateMenu({
        id = 'zrx_restrictedzone:zone:create',
        title = Strings.title,
        menu = 'zrx_restrictedzone:zone:main'
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenEditMenu = function()
    local MENU = {}
    local coords = GetEntityCoords(cache.ped)
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    local job = CORE.Bridge.getVariables().job

    StartCooldown()

    for i, data in pairs(BLIP_DATA) do
        MENU[#MENU + 1] = {
            title = (Strings.edit_title):format(i),
            description = Strings.edit_desc,
            arrow = data.allowedJobs[job.name],
            disabled = not data.allowedJobs[job.name],
            icon = 'fa-solid fa-circle-info',
            iconColor = Config.IconColor,
            metadata = {
                {
                    label = Strings.md_id,
                    value = (Strings.md_id_desc):format(i)
                },
                {
                    label = Strings.md_creator,
                    value = (Strings.md_creator_desc):format(data.creator.name)
                },
                {
                    label = Strings.md_job,
                    value = (Strings.md_job_desc):format(data.creator.job)
                },
                {
                    label = Strings.md_jobGrade,
                    value = (Strings.md_jobGrade_desc):format(data.creator.grade_label, data.creator.grade)
                },
                {
                    label = Strings.md_radius,
                    value = (Strings.md_radius_desc):format(data.radius)
                },
                {
                    label = Strings.md_speedlimit,
                    value = type(data.speedlimit) == 'number' and data.speedlimit .. ' ' .. Strings.unit or Strings.false_
                },
                {
                    label = Strings.md_removecars,
                    value = data.removeCars and Strings.true_ or Strings.false_
                },
                {
                    label = Strings.md_timeout,
                    value = type(data.timeout) == 'number' and data.timeout .. ' ' .. Strings.minutes or Strings.false_
                },
                {
                    label = Strings.md_street,
                    value = (Strings.md_street_desc):format(data.street)
                },
            },
            args = {
                id = i
            },
            onSelect = function(args)
                local input = lib.inputDialog(Strings.title, {
                    {
                        type = 'textarea',
                        label = Strings.i_update_notify,
                        description = Strings.i_update_notify_desc,
                        required = true,
                        default = (Strings.i_update_notify_default):format(street, job.label:upper()),
                        min = 3,
                        max = 200
                    },
                    {
                        type = 'textarea',
                        label = Strings.i_end_notify,
                        description = Strings.i_end_notify_desc,
                        required = true,
                        default = (Strings.i_end_notify_default):format(street, job.label:upper()),
                        min = 3,
                        max = 200
                    },
                    {
                        type = 'checkbox',
                        label = Strings.i_use_playsound,
                        checked = data.playSound
                    },
                    {
                        type = 'number',
                        label = Strings.i_radius,
                        description = Strings.i_radius_desc,
                        required = true,
                        default = data.radius,
                        min = 10,
                        max = 200
                    },
                    {
                        type = 'checkbox',
                        label = Strings.i_use_removecars,
                        checked = data.removeCars
                    },
                    {
                        type = 'number',
                        label = Strings.i_speedlimit,
                        description = Strings.i_speedlimit_desc,
                        required = true,
                        default = type(data.speedlimit) == 'number' and data.speedlimit or 50
                    },
                    {
                        type = 'checkbox',
                        label = Strings.i_use_speedlimit,
                        checked = type(data.speedlimit) == 'number' and data.speedlimit or true
                    },
                    {
                        type = 'number',
                        label = Strings.i_timeout,
                        description = Strings.i_timeout_desc,
                        required = true,
                        default = type(data.timeout) == 'number' and data.timeout or 10,
                        max = 60
                    },
                    {
                        type = 'checkbox',
                        label = Strings.i_use_timeout,
                        checked = type(data.timeout) == 'number' and data.timeout or true
                    },
                })

                if not input then
                    CORE.Bridge.notification(Strings.not_fill)
                    return OpenEditMenu()
                end

                local DATA = {
                    textUpdate = input[1],
                    textEnd = input[2],
                    playSound = input[3],
                    radius = input[4],
                    removeCars = input[5],
                    speedlimit = data[7] == true and data[6] or false,
                    timeout = data[9] == true and data[8] or false,
                }

                TriggerServerEvent('zrx_restrictedzone:server:editSyncBlip', DATA, args.id)

                CreateThread(function()
                    local timeout, alpha = 0, 0.5
                    local r, g, b = Config.IconColor:match('rgba%((%d+),%s*(%d+),%s*(%d+)')
                    r, g, b = tonumber(r), tonumber(g), tonumber(b)

                    while timeout <= 500 do
                        timeout += 1
                        alpha -= 0.001
                        DrawSphere(data.coords.x, data.coords.y, data.coords.z, input[3], r, g, b, alpha)
                        Wait()
                    end
                end)
            end
        }
    end

    CORE.Client.CreateMenu({
        id = 'zrx_restrictedzone:zone:edit',
        title = Strings.title,
        menu = 'zrx_restrictedzone:zone:main'
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenRemoveMenu = function()
    local MENU = {}
    local job = CORE.Bridge.getVariables().job

    StartCooldown()

    for i, data in pairs(BLIP_DATA) do
        MENU[#MENU + 1] = {
            title = (Strings.remove_title):format(i),
            description = Strings.remove_desc,
            arrow = data.allowedJobs[job.name],
            disabled = not data.allowedJobs[job.name],
            icon = 'fa-solid fa-circle-info',
            iconColor = Config.IconColor,
            metadata = {
                {
                    label = Strings.md_id,
                    value = (Strings.md_id_desc):format(i)
                },
                {
                    label = Strings.md_creator,
                    value = (Strings.md_creator_desc):format(data.creator.name)
                },
                {
                    label = Strings.md_job,
                    value = (Strings.md_job_desc):format(data.creator.job)
                },
                {
                    label = Strings.md_jobGrade,
                    value = (Strings.md_jobGrade_desc):format(data.creator.grade_label, data.creator.grade)
                },
                {
                    label = Strings.md_radius,
                    value = (Strings.md_radius_desc):format(data.radius)
                },
                {
                    label = Strings.md_speedlimit,
                    value = type(data.speedlimit) == 'number' and data.speedlimit .. ' ' .. Strings.unit or Strings.false_
                },
                {
                    label = Strings.md_removecars,
                    value = data.removeCars and Strings.true_ or Strings.false_
                },
                {
                    label = Strings.md_timeout,
                    value = type(data.timeout) == 'number' and data.timeout .. ' ' .. Strings.minutes or Strings.false_
                },
                {
                    label = Strings.md_street,
                    value = (Strings.md_street_desc):format(data.street)
                },
            },
            args = {
                id = i
            },
            onSelect = function(args)
                local input = lib.inputDialog(Strings.title, {
                    {
                        type = 'textarea',
                        label = Strings.notify,
                        description = Strings.i_end_notify_desc,
                        required = true,
                        default = (Strings.i_end_notify_default):format(data.street, job.label:upper()),
                        min = 3,
                        max = 200
                    },
                })

                if not input then
                    CORE.Bridge.notification(Strings.not_fill)
                    return OpenRemoveMenu()
                end

                local alert = lib.alertDialog({
                    header = Strings.sure,
                    content = Strings.sure_desc,
                    centered = true,
                    cancel = true
                })

                if alert == 'cancel' then
                    return OpenRemoveMenu()
                end

                local DATA = {
                    textEnd = input[1]
                }

                TriggerServerEvent('zrx_restrictedzone:server:removeSyncBlip', DATA, args.id)

                CreateThread(function()
                    local timeout, alpha = 0, 0.5
                    local r, g, b = Config.IconColor:match('rgba%((%d+),%s*(%d+),%s*(%d+)')
                    r, g, b = tonumber(r), tonumber(g), tonumber(b)

                    while timeout <= 500 do
                        timeout += 1
                        alpha -= 0.001
                        DrawSphere(data.coords.x, data.coords.y, data.coords.z, data.radius, r, g, b, alpha)
                        Wait()
                    end
                end)
            end
        }
    end

    CORE.Client.CreateMenu({
        id = 'zrx_restrictedzone:zone:remove',
        title = Strings.title,
        menu = 'zrx_restrictedzone:zone:main'
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

StartCooldown = function()
    if not Config.Cooldown then return end
    COOLDOWN = true

    CreateThread(function()
        SetTimeout(Config.Cooldown * 1000, function()
            COOLDOWN = false
        end)
    end)
end