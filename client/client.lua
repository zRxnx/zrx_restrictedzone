CORE = exports.zrx_utility:GetUtility()
COOLDOWN = false
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
local vector3 = vector3
local NetworkIsPlayerActive = NetworkIsPlayerActive

CORE.Client.RegisterKeyMappingCommand(Config.Command, Strings.cmd_desc, Config.Key, function()
    OpenMainMenu()
end)

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
    local temp = Config.Templates[data.cindex]

    if data.playSound then
        PlaySoundFrontend(-1, 'BASE_JUMP_PASSED', 'HUD_AWARDS', 0)
    end

    if data.speedlimit then
        SPEEDLIMIT_DATA[#SPEEDLIMIT_DATA + 1] = {
            speed =  Config.KPH and data.speedlimit / 3.6 or data.speedlimit / 2.236936,
            coords = data.coords,
            range = data.radius,
            allowedJobs = data.allowedJobs
        }

        local pedCoords = GetEntityCoords(cache.ped)
        if DoesEntityExist(cache.vehicle) and #(vector3(data.coords.x, data.coords.y, data.coords.z) - vector3(pedCoords.x, pedCoords.y, pedCoords.z)) <= data.radius then
            SetVehicleMaxSpeed(cache.vehicle, data.speed)
            Entity(cache.vehicle).state.zrx_r_speedlimit = {}
            Entity(cache.vehicle).state.zrx_r_speedlimit[#SPEEDLIMIT_DATA] = true
        end
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
        cindex = data.cindex,
        displayBlip = temp.displayBlip(vector3(data.coords.x, data.coords.y, data.coords.z)),
        radiusBlip = temp.radiusBlip(vector3(data.coords.x, data.coords.y, data.coords.z), data.radius),
        speedlimit = data.speedlimit,
        timeout = data.timeout,
        removeCars = data.removeCars,
        playSound = data.playSound,
        speedlimitI = data.speedlimit == true and #SPEEDLIMIT_DATA or false,
        removeCarsI = data.removeCars == true and #REMOVECARS_DATA or false,
        street = data.street,
        radius = data.radius,
        coords = data.coords
    }
end)

RegisterNetEvent('zrx_restrictedzone:client:editBlip', function(data, index)
    local oldData = BLIP_DATA[index]
    local temp = Config.Templates[data.cindex]

    if data.playSound and not oldData.playSound then
        PlaySoundFrontend(-1, 'BASE_JUMP_PASSED', 'HUD_AWARDS', 0)
    end

    if not data.playSound and oldData.playSound then
        PlaySoundFrontend(-1, 'PEYOTE_COMPLETED', 'HUD_AWARDS', 0)
    end

    if data.speedlimit then
        SPEEDLIMIT_DATA[data.speedlimitI or #SPEEDLIMIT_DATA + 1] = {
            speed =  Config.KPH and data.speedlimit / 3.6 or data.speedlimit / 2.236936,
            coords = data.coords,
            range = data.radius,
            allowedJobs = data.allowedJobs
        }

        local pedCoords = GetEntityCoords(cache.ped)
        if DoesEntityExist(cache.vehicle) and #(vector3(data.coords.x, data.coords.y, data.coords.z) - vector3(pedCoords.x, pedCoords.y, pedCoords.z)) <= data.radius then
            SetVehicleMaxSpeed(cache.vehicle, data.speed)
            Entity(cache.vehicle).state.zrx_r_speedlimit = {}
            Entity(cache.vehicle).state.zrx_r_speedlimit[data.speedlimitI or #SPEEDLIMIT_DATA] = true
        end
    end

    if data.removeCars then
        REMOVECARS_DATA[data.removeCarsI or #REMOVECARS_DATA + 1] = {
            coords = data.coords,
            range = data.radius
        }
    end

    RemoveBlip(oldData.displayBlip)
    RemoveBlip(oldData.radiusBlip)

    BLIP_DATA[index] = {
        creator = data.creator,
        allowedJobs = data.allowedJobs,
        cindex = data.cindex,
        displayBlip = temp.displayBlip(vector3(data.coords.x, data.coords.y, data.coords.z)),
        radiusBlip = temp.radiusBlip(vector3(data.coords.x, data.coords.y, data.coords.z), data.radius),
        speedlimit = data.speedlimit,
        timeout = data.timeout,
        removeCars = data.removeCars,
        playSound = data.playSound,
        speedlimitI = data.speedlimit == true and #SPEEDLIMIT_DATA or false,
        removeCarsI = data.removeCars == true and #REMOVECARS_DATA or false,
        street = data.street,
        radius = data.radius,
        coords = data.coords
    }
end)

RegisterNetEvent('zrx_restrictedzone:client:removeBlip', function(index)
    local temp = BLIP_DATA[index]

    if temp.playSound then
        PlaySoundFrontend(-1, 'PEYOTE_COMPLETED', 'HUD_AWARDS', 0)
    end

    if temp.speedlimit then
        if DoesEntityExist(cache.vehicle) and Entity(cache.vehicle).state.zrx_r_speedlimit[temp.speedlimitI] then
            SetVehicleMaxSpeed(cache.vehicle, 0.0)
        end

        SPEEDLIMIT_DATA[temp.speedlimitI] = nil
    end

    if temp.removeCars then
        REMOVECARS_DATA[temp.removeCarsI] = nil
    end

    RemoveBlip(temp.displayBlip)
    RemoveBlip(temp.radiusBlip)

    BLIP_DATA[index] = nil
end)

CreateThread(function()
    local pedCoords, popType, vehCoords
    local vehicles = {}

    lib.waitFor(function()
        return NetworkIsPlayerActive(cache.playerId)
    end, 'Timeout', 120000)

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

        if #SPEEDLIMIT_DATA >= 1 and DoesEntityExist(cache.vehicle) then
            pedCoords = GetEntityCoords(cache.ped)

            Entity(cache.vehicle).state.zrx_r_speedlimit = {}
            SetVehicleMaxSpeed(cache.vehicle, 0.0)
            for i, data in pairs(SPEEDLIMIT_DATA) do
                if not data.allowedJobs[CORE.Bridge.getVariables().job.name] and #(vector3(pedCoords.x, pedCoords.y, pedCoords.z) - vector3(data.coords.x, data.coords.y, data.coords.z)) <= data.range then
                    Entity(cache.vehicle).state.zrx_r_speedlimit[i] = true
                    SetVehicleMaxSpeed(cache.vehicle, data.speed)
                end
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