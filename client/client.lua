ESX, COOLDOWN = Config.EsxImport(), false
BLIP_DATA, SPEEDLIMIT_DATA, REMOVECARS_DATA = {}, {}, {}
local DoesEntityExist = DoesEntityExist
local GetCurrentResourceName = GetCurrentResourceName
local RemoveBlip = RemoveBlip
local SetVehicleMaxSpeed = SetVehicleMaxSpeed
local PlaySoundFrontend = PlaySoundFrontend
local GetEntityCoords = GetEntityCoords
local GetGamePool = GetGamePool
local GetPedInVehicleSeat = GetPedInVehicleSeat
local IsPedAPlayer = IsPedAPlayer
local SetEntityAsMissionEntity = SetEntityAsMissionEntity
local DeleteVehicle = DeleteVehicle
local GetEntityPopulationType = GetEntityPopulationType

RegisterNetEvent('esx:playerLoaded',function(xPlayer)
    ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

RegisterCommand(Config.Command, function() OpenMainMenu() end)
RegisterKeyMapping(Config.Command, Strings.cmd_sug, 'keyboard', Config.Key)
TriggerEvent('chat:addSuggestion', ('/%s'):format(Config.Command), Strings.cmd_sug, {})

RegisterNetEvent('onClientResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end

    if DoesEntityExist(cache.vehicle) then
        SetVehicleMaxSpeed(cache.vehicle, 0.0)
    end

    for i, data in pairs(BLIP_DATA) do
        RemoveBlip(data.displayBlip)
        RemoveBlip(data.radiusBlip)
    end
end)

RegisterNetEvent('zrx_restrictedzone:client:startBlip', function(data)
    local temp = Config.Templates[data.index]

    if data.playSound then
        PlaySoundFrontend(-1, 'BASE_JUMP_PASSED', 'HUD_AWARDS', 0, 1)
    end

    if data.speedlimit then
        SPEEDLIMIT_DATA[#SPEEDLIMIT_DATA + 1] = {
            speed =  Config.KPH and data.speedlimit / 3.6 or data.speedlimit / 2.236936,
            coords = data.coords,
            range = data.radius,
            allowedJobs = data.allowedJobs
        }
    end

    if data.removeCars then
        REMOVECARS_DATA[#REMOVECARS_DATA + 1] = {
            coords = data.coords,
            range = data.radius
        }
    end

    BLIP_DATA[#BLIP_DATA + 1] = {
        creator = data.creator,
        allowedJobs = data.allowedJobs,
        index = data.index,
        displayBlip = temp.displayBlip(vector3(data.coords.x, data.coords.y, data.coords.z)),
        radiusBlip = temp.radiusBlip(vector3(data.coords.x, data.coords.y, data.coords.z), data.radius),
        speedlimit = data.speedlimit,
        timeout = data.timeout,
        removeCars = data.removeCars,
        playSound = data.playSound,
        speedlimitI = #SPEEDLIMIT_DATA,
        removeCarsI = #REMOVECARS_DATA,
        street = data.street,
        radius = data.radius
    }
end)

RegisterNetEvent('zrx_restrictedzone:client:removeBlip', function(id)
    local temp = BLIP_DATA[id]

    if temp.playSound then
        PlaySoundFrontend(-1, "PEYOTE_COMPLETED", "HUD_AWARDS", 0, 1)
    end

    if temp.speedlimit > 0 then
        if DoesEntityExist(cache.vehicle) then
            SetVehicleMaxSpeed(cache.vehicle, 0.0)
        end

        SPEEDLIMIT_DATA[temp.speedlimitI] = nil
    end

    if temp.removeCars then
        REMOVECARS_DATA[temp.removeCarsI] = nil
    end

    RemoveBlip(temp.displayBlip)
    RemoveBlip(temp.radiusBlip)

    BLIP_DATA[id] = nil
end)

CreateThread(function()
    local pedCoords, popType, vehCoords
    local vehicles = {}

    while true do
        if #REMOVECARS_DATA >= 1 then
            pedCoords = GetEntityCoords(cache.ped)
            vehicles = GetGamePool('CVehicle')

            for i, data in pairs(REMOVECARS_DATA) do
                if #(vector3(pedCoords.x, pedCoords.y, pedCoords.z) - vector3(data.coords.x, data.coords.y, data.coords.z)) <= data.range then
                    for k, data2 in pairs(vehicles) do
                        vehCoords = GetEntityCoords(data2)
                        popType = GetEntityPopulationType(data2)

                        --| GetPedInVehicleSeat(data2, -1) ~= 0 and not IsPedAPlayer(GetPedInVehicleSeat(data2, -1)) | I think pop type is a better check
                        if #(vector3(vehCoords.x, vehCoords.y, vehCoords.z) - vector3(data.coords.x, data.coords.y, data.coords.z)) <= data.range + 20 and
                        (popType == 2 or popType == 3 or popType == 4 or popType == 5) then
                            SetEntityAsMissionEntity(data2, true, true)
                            DeleteVehicle(data2)
                        end
                    end
                end
            end
        end

        if #SPEEDLIMIT_DATA >= 1 then
            pedCoords = GetEntityCoords(cache.ped)

            SetVehicleMaxSpeed(cache.vehicle, 0.0)
            for i, data in pairs(SPEEDLIMIT_DATA) do
                if data.allowedJobs[ESX.PlayerData.job.name] then goto continue end

                if #(vector3(pedCoords.x, pedCoords.y, pedCoords.z) - vector3(data.coords.x, data.coords.y, data.coords.z)) <= data.range then
                    SetVehicleMaxSpeed(cache.vehicle, data.speed)
                end

                ::continue::
            end
        end

        Wait(1000)
    end
end)

exports('activeBlips', function()
    return BLIP_DATA
end)

exports('hasCooldown', function()
    return COOLDOWN
end)