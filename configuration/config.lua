Config = {}

--| Discord Webhook in 'configuration/webhook.lua'
Config.Command = 'restrictedzone' --| Command
Config.Key = 'F11' --| Note: Its a keymapping
Config.Cooldown = 3 --| Note: Between each zone creation | In seconds
Config.CheckForUpdates = true --| Check for updates?
Config.IconColor  = 'rgba(173, 216, 230, 1)' --| rgba format
Config.KPH = true --| Use KPH or MPH?

--| You can select these templates ingame
Config.Templates = {
    {
        name = 'LSPD #1',
        displayBlip = function(coords) --| Change it if you know what you are doing
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

            SetBlipSprite(blip, 161)
            SetBlipColour(blip, 1)
            SetBlipScale(blip, 1.0)
            SetBlipAlpha(blip, 255)
            SetBlipAsShortRange(blip, false)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName('Restricted Zone')
            EndTextCommandSetBlipName(blip)

            return blip
        end,
        radiusBlip = function(coords, radius) --| Change it if you know what you are doing
            local blip = AddBlipForRadius(coords.x, coords.y, coords.z, radius)

            SetBlipAlpha(blip, 140)
            SetBlipColour(blip, 1)

            return blip
        end,
        allowedJobs = {
            police = true
        }
    },
    {
        name = 'SHERIFF #1',
        displayBlip = function(coords)
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

            SetBlipSprite(blip, 161)
            SetBlipColour(blip, 2)
            SetBlipScale(blip, 1.0)
            SetBlipAlpha(blip, 255)
            SetBlipAsShortRange(blip, false)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName('Restricted Zone')
            EndTextCommandSetBlipName(blip)

            return blip
        end,
        radiusBlip = function(coords, radius)
            local blip = AddBlipForRadius(coords.x, coords.y, coords.z, radius)

            SetBlipAlpha(blip, 140)
            SetBlipColour(blip, 2)

            return blip
        end,
        allowedJobs = {
            police = true,
            sheriff = true
        }
    }
}

--| Place here your punish actions
Config.PunishPlayer = function(player, reason)
    if not IsDuplicityVersion() then return end
    if Webhook.Settings.punish then
        DiscordLog(player, 'PUNISH', reason, 'punish')
    end

    DropPlayer(player, reason)
end

--| Place your checks here before the personal menu opens
Config.CanOpenMenu = function()
    return ESX.IsPlayerLoaded()
end

--| Place here your notification
Config.Notification = function(player, msg)
    if IsDuplicityVersion() then
        TriggerClientEvent('esx:showNotification', player, msg, 'info')
    else
        ESX.ShowNotification(msg)
    end
end

--| Place here your esx import
--| Change it if you know what you are doing
Config.EsxImport = function()
	if IsDuplicityVersion() then
		return exports.es_extended:getSharedObject()
	else
		return exports.es_extended:getSharedObject()
	end
end