OpenMainMenu = function()
    local MENU = {}
    local isAllowed = lib.callback.await('zrx_restrictedzone:server:isAllowed', 1000)

    if not isAllowed then
        ZRX_UTIL.notify(nil, Strings.no_perms)
        return
    end

    MENU[#MENU + 1] = {
        title = Strings.main_create_title,
        description = Strings.main_create_desc,
        arrow = true,
        icon = 'fa-solid fa-plus',
        iconColor = Config.IconColor,
        onSelect = function()
            OpenCreateMenu()
        end
    }

    MENU[#MENU + 1] = {
        title = Strings.main_edit_title,
        description = Strings.main_edit_desc,
        arrow = #BLIP_DATA > 0,
        disabled = #BLIP_DATA <= 0,
        icon = 'fa-solid fa-pen-to-square',
        iconColor = Config.IconColor,
        onSelect = function()
            OpenEditMenu()
        end
    }

    MENU[#MENU + 1] = {
        title = Strings.main_remove_title,
        description = Strings.main_remove_desc,
        arrow = #BLIP_DATA > 0,
        disabled = #BLIP_DATA <= 0,
        icon = 'fa-solid fa-trash',
        iconColor = Config.IconColor,
        onSelect = function()
            OpenRemoveMenu()
        end
    }

    ZRX_UTIL.createMenu({
        id = 'zrx_restrictedzone:openMainMenu',
        title = Strings.title,
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenCreateMenu = function()
    local MENU = {}
    local coords = GetEntityCoords(cache.ped)
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))

    for name, data in pairs(Config.Template) do
        MENU[#MENU + 1] = {
            title = name,
            description = Strings.create_desc,
            arrow = true,
            icon = 'fa-solid fa-plus',
            iconColor = Config.IconColor,
            onSelect = function()
                local INPUT = {}

                INPUT[#INPUT + 1] = {
                    type = 'textarea',
                    label = Strings.create_md_label,
                    description = Strings.create_md_desc,
                    default = Strings.create_md_default:format(street),
                    required = true,
                    min = 10,
                    max = 200,
                }

                INPUT[#INPUT + 1] = {
                    type = 'number',
                    label = Strings.create_md_radius_label,
                    description = Strings.create_md_radius_desc,
                    default = 50,
                    required = true,
                    min = Config.Radius.min,
                    max = Config.Radius.max,
                }

                INPUT[#INPUT + 1] = {
                    type = 'checkbox',
                    label = Strings.create_md_timeout_label,
                    checked = true,
                }

                INPUT[#INPUT + 1] = {
                    type = 'number',
                    label = Strings.create_md_timeout_dur_label,
                    description = Strings.create_md_timeout_dur_desc,
                    default = 15,
                    required = false,
                    min = 10,
                    max = 60,
                }

                INPUT[#INPUT + 1] = {
                    type = 'textarea',
                    label = Strings.create_md_timeout_text_label,
                    description = Strings.create_md_timeout_text_desc,
                    default = Strings.create_md_timeout_text_default:format(street),
                    required = false,
                    min = 10,
                    max = 200,
                }

                INPUT[#INPUT + 1] = {
                    type = 'checkbox',
                    label = Strings.create_md_speedlimit_label,
                    checked = true,
                }

                INPUT[#INPUT + 1] = {
                    type = 'number',
                    label = Strings.create_md_speedlimit_speed_label,
                    description = Strings.create_md_speedlimit_speed_desc,
                    default = 50,
                    required = false,
                    min = 10,
                    max = 200,
                }

                INPUT[#INPUT + 1] = {
                    type = 'input',
                    label = Strings.create_md_blip_label,
                    description = Strings.create_md_blip_desc,
                    default = data.blip.displayText,
                    required = true,
                    min = 5,
                    max = 20,
                }

                local input = lib.inputDialog(Strings.title, INPUT)

                if not input then
                    lib.showContext('zrx_restrictedzone:openMainMenu')
                    return
                end

                local DATA = {}

                DATA.text = input[1]
                DATA.radius = input[2]

                if input[3] then
                    DATA.timeout = {}
                    DATA.timeout.time = input[4]
                    DATA.timeout.text = input[5]
                else
                    DATA.timeout = false
                end

                if input[6] then
                    DATA.speedlimit = {}
                    DATA.speedlimit.speed = input[7]
                else
                    DATA.speedlimit = false
                end

                DATA.street = street
                DATA.coords = coords
                DATA.index = name
                DATA.displayText = input[8]

                print(json.encode(DATA, { indent = true }))

                TriggerServerEvent('zrx_restrictedzone:server:zone', 'create', DATA)
            end
        }
    end

    ZRX_UTIL.createMenu({
        id = 'zrx_restrictedzone:openCreateMenu',
        title = Strings.create_title,
        menu = 'zrx_restrictedzone:openMainMenu',
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenEditMenu = function()
    local MENU, METADATA = {}, {}

    for bId, data in pairs(BLIP_DATA) do
        METADATA = {}

        METADATA[#METADATA + 1] = {
            label = Strings.edit_md_creator_label, value = data.creator.name
        }

        METADATA[#METADATA + 1] = {
            label = Strings.edit_md_creator_job_label, value = ('%s - %s'):format(data.creator.job, data.creator.grade)
        }

        METADATA[#METADATA + 1] = {
            label = Strings.edit_md_radius, value = data.radius
        }

        if data.speedlimit then
            METADATA[#METADATA + 1] = {
                label = Strings.edit_md_speedlimit, value = data.speedlimit.speed
            }
        end

        if data.timeout then
            METADATA[#METADATA + 1] = {
                label = Strings.edit_md_timeout, value = data.timeout.time
            }
        end

        MENU[#MENU + 1] = {
            title = ('%s - %s'):format(data.index, bId),
            description = Strings.edit_update_desc,
            arrow = true,
            icon = 'fa-solid fa-circle-info',
            iconColor = Config.IconColor,
            metadata = METADATA,
            onSelect = function()
                local INPUT = {}

                INPUT[#INPUT + 1] = {
                    type = 'textarea',
                    label = Strings.edit_update_update_label,
                    description = Strings.edit_update_update_desc,
                    default = Strings.edit_update_update_default:format(data.street),
                    required = true,
                    min = 10,
                    max = 200
                }

                INPUT[#INPUT + 1] = {
                    type = 'number',
                    label = Strings.edit_update_radius_label,
                    description = Strings.edit_update_radius_desc,
                    default = data.radius,
                    required = true,
                    min = Config.Radius.min,
                    max = Config.Radius.max,
                }

                local input = lib.inputDialog(Strings.title, INPUT)

                if not input then
                    lib.showContext('zrx_restrictedzone:openMainMenu')
                    return
                end

                local DATA = {}

                DATA.update = input[1]
                DATA.radius = input[2]
                DATA.index = data.index
                DATA.bId = data.bId

                TriggerServerEvent('zrx_restrictedzone:server:zone', 'update', DATA)
            end
        }
    end

    ZRX_UTIL.createMenu({
        id = 'zrx_restrictedzone:openEditMenu',
        title = Strings.edit_update_title,
        menu = 'zrx_restrictedzone:openMainMenu',
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end

OpenRemoveMenu = function()
    local MENU, METADATA = {}, {}

    for bId, data in pairs(BLIP_DATA) do
        METADATA = {}

        METADATA[#METADATA + 1] = {
            label = Strings.remove_md_creator_label, value = data.creator.name
        }

        METADATA[#METADATA + 1] = {
            label = Strings.remove_md_creator_job_label, value = ('%s - %s'):format(data.creator.job, data.creator.grade)
        }

        METADATA[#METADATA + 1] = {
            label = Strings.remove_md_radius, value = data.radius
        }

        if data.speedlimit then
            METADATA[#METADATA + 1] = {
                label = Strings.remove_md_speedlimit, value = data.speedlimit.speed
            }
        end

        if data.timeout then
            METADATA[#METADATA + 1] = {
                label = Strings.remove_md_timeout, value = data.timeout.time
            }
        end

        MENU[#MENU + 1] = {
            title = ('%s - %s'):format(data.index, bId),
            description = Strings.remove_update_desc,
            arrow = true,
            icon = 'fa-solid fa-circle-info',
            iconColor = Config.IconColor,
            metadata = METADATA,
            onSelect = function()
                local INPUT = {}

                INPUT[#INPUT + 1] = {
                    type = 'textarea',
                    label = Strings.remove_text_label,
                    description = Strings.remove_text_desc,
                    required = true,
                    min = 10,
                    max = 200
                }

                local input = lib.inputDialog(Strings.title, INPUT)

                if not input then
                    lib.showContext('zrx_restrictedzone:openMainMenu')
                    return
                end

                local alert = lib.alertDialog({
                    header = Strings.remove_alert_head,
                    content = Strings.remove_alert_content,
                    centered = true,
                    cancel = true
                })

                if alert == 'cancel' then
                    lib.showContext('zrx_restrictedzone:openMainMenu')
                    return
                end

                local DATA = BLIP_DATA[bId]

                DATA.textEnd = input[1]
                
                TriggerServerEvent('zrx_restrictedzone:server:zone', 'remove', DATA)
            end
        }
    end

    ZRX_UTIL.createMenu({
        id = 'zrx_restrictedzone:openRemoveMenu',
        title = Strings.remove_update_title,
        menu = 'zrx_restrictedzone:openMainMenu',
    }, MENU, Config.Menu.type ~= 'menu', Config.Menu.postition)
end