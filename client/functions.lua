local GetEntityCoords = GetEntityCoords
local DrawSphere = DrawSphere
local GetStreetNameFromHashKey = GetStreetNameFromHashKey
local GetStreetNameAtCoord = GetStreetNameAtCoord

OpenMainMenu = function()
    if not Config.CanOpenMenu() then return end

    local MENU = {}
    local isAllowed = false

    for i, data in pairs(Config.Templates) do
        if data.allowedJobs[ESX.PlayerData.job.name] then
            isAllowed = true
            break
        end
    end

    if not isAllowed then
        return Config.Notification(nil, Strings.no_perms)
    end

    ESX.UI.Menu.CloseAll()
    ESX.CloseContext()

    MENU[#MENU + 1] = {
        title = Strings.zone_create,
        description = Strings.zone_create_desc,
        arrow = #Config.Templates > 0 or not COOLDOWN,
        disabled = #Config.Templates <= 0 or COOLDOWN,
        icon = 'fa-solid fa-plus',
        iconColor = Config.IconColor,
        onSelect = function()
            OpenCreateMenu()
        end
    }

    MENU[#MENU + 1] = {
        title = Strings.zone_remove,
        description = Strings.zone_remove_desc,
        arrow = #BLIP_DATA > 0 or not COOLDOWN,
        disabled = #BLIP_DATA <= 0 or COOLDOWN,
        icon = 'fa-solid fa-trash',
        iconColor = Config.IconColor,
        onSelect = function()
            OpenRemoveMenu()
        end
    }

    lib.registerContext({
        id = 'zrx_restrictedzone:zone:main',
        title = Strings.title,
        options = MENU,
    })

    lib.showContext('zrx_restrictedzone:zone:main')
end

OpenCreateMenu = function()
    local MENU = {}
    local coords = GetEntityCoords(cache.ped)
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))

    StartCooldown()

    for k, data in pairs(Config.Templates) do
        MENU[#MENU + 1] = {
            title = (Strings.create_click):format(data.name),
            description = Strings.create_click_desc,
            arrow = data.allowedJobs[ESX.PlayerData.job.name],
            disabled = not data.allowedJobs[ESX.PlayerData.job.name],
            icon = 'fa-solid fa-plus',
            iconColor = Config.IconColor,
            args = {
                id = k
            },
            onSelect = function(args)
                local input = lib.inputDialog(Strings.title, {
                    { type = 'textarea', label = Strings.i_start_notify, description = Strings.i_start_notify_desc, required = true, default = (Strings.i_start_notify_default):format(street, ESX.PlayerData.job.label:upper()), min = 3, max = 50 },
                    { type = 'textarea', label = Strings.i_end_notify, description = Strings.i_end_notify_desc, required = true, default = (Strings.i_end_notify_default):format(street, ESX.PlayerData.job.label:upper()), min = 3, max = 50 },
                    { type = 'number', label = Strings.i_radius, description = Strings.i_radius_desc, required = true, default = 50, min = 50, max = 200 },
                    { type = 'number', label = Strings.i_speedlimit, description = Strings.i_speedlimit_desc, required = true, default = 50 },
                    { type = 'number', label = Strings.i_timeout, description = Strings.i_timeout_desc, required = true, default = 10, max = 60 },
                    { type = 'checkbox', label = Strings.i_use_removecars, checked = true },
                    { type = 'checkbox', label = Strings.i_use_playsound, checked = true },
                    { type = 'checkbox', label = Strings.i_use_speedlimit, checked = true },
                    { type = 'checkbox', label = Strings.i_use_timeout, checked = false },
                })

                if not input then
                    Config.Notification(nil, Strings.not_fill)
                    return OpenCreateMenu()
                end

                TriggerServerEvent('zrx_restrictedzone:server:startSyncBlip', input, args.id, coords, street)

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

    lib.registerContext({
        id = 'zrx_restrictedzone:zone:create',
        title = Strings.title,
        options = MENU,
        menu = 'zrx_restrictedzone:zone:main'
    })

    lib.showContext('zrx_restrictedzone:zone:create')
end

OpenRemoveMenu = function()
    local MENU = {}

    StartCooldown()

    for i, data in pairs(BLIP_DATA) do
        MENU[#MENU + 1] = {
            title = (Strings.remove_title):format(i),
            description = Strings.remove_desc,
            arrow = data.allowedJobs[ESX.PlayerData.job.name],
            disabled = not data.allowedJobs[ESX.PlayerData.job.name],
            icon = 'fa-solid fa-circle-info',
            iconColor = Config.IconColor,
            metadata = {
                { label = Strings.md_cid, value = (Strings.md_cid_desc):format(data.index) },
                { label = Strings.md_creator, value = (Strings.md_creator_desc):format(data.creator.name) },
                { label = Strings.md_job, value = (Strings.md_job_desc):format(data.creator.job) },
                { label = Strings.md_jobGrade, value = (Strings.md_jobGrade_desc):format(data.creator.grade_label, data.creator.grade) },
                { label = Strings.md_radius, value = (Strings.md_radius_desc):format(data.radius) },
                { label = Strings.md_speedlimit, value = (Strings.md_speedlimit_desc):format((type(data.speedlimit) == 'number' and data.speedlimit) or Strings.false_) },
                { label = Strings.md_removecars, value = (Strings.md_removecars_desc):format(data.removeCars and Strings.true_ or Strings.false_) },
                { label = Strings.md_timeout, value = (Strings.md_timeout_desc):format((type(data.timeout) == 'number' and data.timeout) or Strings.false_) },
                { label = Strings.md_street, value = (Strings.md_street_desc):format(data.street) },
            },
            args = {
                id = i
            },
            onSelect = function(args)
                local input = lib.inputDialog(Strings.title, {
                    { type = 'textarea', label = Strings.notify, description = Strings.i_end_notify_desc, required = true, default = (Strings.i_end_notify_default):format(data.street, ESX.PlayerData.job.label:upper()), min = 3, max = 50 },
                })

                if not input then
                    Config.Notification(nil, Strings.not_fill)
                    return OpenRemoveMenu()
                end

                TriggerServerEvent('zrx_restrictedzone:server:removeSyncBlip', input, args)
            end
        }
    end

    lib.registerContext({
        id = 'zrx_restrictedzone:zone:remove',
        title = Strings.title,
        options = MENU,
        menu = 'zrx_restrictedzone:zone:main'
    })

    lib.showContext('zrx_restrictedzone:zone:remove')
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