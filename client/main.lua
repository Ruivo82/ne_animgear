local currentGear = nil
local lastAnimAt = 0
local animBusy = false
local animToken = 0
local activeAnim = nil -- { ped, dict, clip }
local carDictLoaded = false
local resolvedBike = nil -- { dict, clip, duration } | false

local MOTORCYCLE_CLASS = 8

local function loadDict(dict)
    if not dict or dict == '' then return false end
    if HasAnimDictLoaded(dict) then return true end
    RequestAnimDict(dict)
    local timeout = GetGameTimer() + 3000
    while not HasAnimDictLoaded(dict) do
        if GetGameTimer() > timeout then return false end
        Wait(10)
    end
    return true
end

local function clipExists(dict, clip)
    if not dict or not clip then return false end
    local dur = GetAnimDuration(dict, clip)
    return type(dur) == 'number' and dur > 0.01
end

local function ensureCarAnim()
    if carDictLoaded then return true end
    carDictLoaded = loadDict(Config.Car.dict) and clipExists(Config.Car.dict, Config.Car.clip)
    return carDictLoaded
end

local function resolveBikeAnim()
    if resolvedBike ~= nil then
        return resolvedBike ~= false and resolvedBike or nil
    end

    local candidates = Config.Bike and Config.Bike.candidates or {}
    for i = 1, #candidates do
        local c = candidates[i]
        if c and c.dict and c.clip and loadDict(c.dict) and clipExists(c.dict, c.clip) then
            resolvedBike = {
                dict = c.dict,
                clip = c.clip,
                duration = c.duration or Config.Bike.duration,
            }
            return resolvedBike
        end
    end

    resolvedBike = false
    return nil
end

local function isAllowedVehicle(vehicle)
    local class = GetVehicleClass(vehicle)
    local allowed = Config.allowedClasses
    if not allowed or not allowed[class] then
        return false
    end
    local model = GetEntityModel(vehicle)
    if Config.blockedModels and Config.blockedModels[model] then
        return false
    end
    return true
end

local function stopActiveAnim()
    animToken = animToken + 1
    animBusy = false
    if activeAnim then
        local ped = activeAnim.ped
        if ped and DoesEntityExist(ped) then
            StopAnimTask(ped, activeAnim.dict, activeAnim.clip, 1.0)
        end
        activeAnim = nil
    end
end

local function playAnim(dict, clip, duration, flag, blendIn, blendOut)
    if animBusy then return end
    if not dict or not clip then return end

    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) or IsPedRagdoll(ped) or IsEntityDead(ped) then
        return
    end

    animBusy = true
    animToken = animToken + 1
    local token = animToken
    local dur = duration or 600

    activeAnim = { ped = ped, dict = dict, clip = clip }

    TaskPlayAnim(
        ped,
        dict,
        clip,
        blendIn or 8.0,
        blendOut or 8.0,
        dur,
        flag or 48,
        0.0,
        false,
        false,
        false
    )

    SetTimeout(dur, function()
        if token ~= animToken then return end
        if activeAnim and activeAnim.dict == dict and activeAnim.clip == clip then
            if DoesEntityExist(ped) and IsEntityPlayingAnim(ped, dict, clip, 3) then
                StopAnimTask(ped, dict, clip, 1.0)
            end
            activeAnim = nil
        end
        animBusy = false
    end)
end

local function playCarShift()
    if not Config.Car or not Config.Car.enabled then return end
    if not ensureCarAnim() then return end
    playAnim(
        Config.Car.dict,
        Config.Car.clip,
        Config.Car.duration,
        Config.Car.flag,
        Config.Car.blendIn,
        Config.Car.blendOut
    )
end

local function playBikeShift()
    if not Config.Bike or not Config.Bike.enabled then return end

    local resolved = resolveBikeAnim()
    if not resolved then
        -- Sem clip de pé disponível: NÃO usar animação de mão
        return
    end

    playAnim(
        resolved.dict,
        resolved.clip,
        resolved.duration or Config.Bike.duration,
        Config.Bike.flag,
        Config.Bike.blendIn,
        Config.Bike.blendOut
    )
end

local function shouldSkipForSpeed(vehicle, previousGear, newGear)
    local minSpeed = Config.minSpeedKmh or 0.0
    if minSpeed <= 0.0 then return false end

    local speedKmh = GetEntitySpeed(vehicle) * 3.6
    if speedKmh >= minSpeed then return false end

    -- Com travão de mão ativo não anima
    if GetVehicleHandbrake(vehicle) then
        return true
    end

    -- Parado: ainda anima mudanças que envolvem N/R (gear 0)
    if previousGear == 0 or newGear == 0 then
        return false
    end

    return true
end

local function onGearChanged(vehicle, previousGear, newGear)
    if not GetIsVehicleEngineRunning(vehicle) then
        currentGear = newGear
        return
    end

    local now = GetGameTimer()
    if now - lastAnimAt < (Config.cooldownMs or 450) then
        currentGear = newGear
        return
    end

    if shouldSkipForSpeed(vehicle, previousGear, newGear) then
        currentGear = newGear
        return
    end

    lastAnimAt = now
    currentGear = newGear

    if GetVehicleClass(vehicle) == MOTORCYCLE_CLASS then
        playBikeShift()
    else
        playCarShift()
    end
end

CreateThread(function()
    while true do
        local waitMs = 400
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 then
            local isDriver = GetPedInVehicleSeat(vehicle, -1) == ped
            local engineRunning = GetIsVehicleEngineRunning(vehicle)
            if (not Config.driverOnly or isDriver) and engineRunning and isAllowedVehicle(vehicle) then
                waitMs = Config.pollMs or 80
                local gear = GetVehicleCurrentGear(vehicle)

                if currentGear == nil then
                    currentGear = gear
                elseif gear ~= currentGear then
                    onGearChanged(vehicle, currentGear, gear)
                end
            else
                if currentGear ~= nil then
                    currentGear = nil
                    stopActiveAnim()
                end
            end
        else
            if currentGear ~= nil then
                currentGear = nil
                stopActiveAnim()
            end
            waitMs = 500
        end

        Wait(waitMs)
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    stopActiveAnim()
end)
