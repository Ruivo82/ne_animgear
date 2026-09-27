Config = {}

--- Polling / anti-spam
Config.pollMs = 80
Config.cooldownMs = 450

--- Velocidade mínima (km/h). Abaixo disto só anima mudanças envolvendo N/R (gear 0).
Config.minSpeedKmh = 2.0

--- Só condutor
Config.driverOnly = true

--[[
  Só carro + mota.
  Classes GTA permitidas (whitelist). Tudo o resto é ignorado.
  0-7  carros · 8 motas · 9 off-road · 12 carrinhas · 17 service · 18 emergência · 22 open-wheel
]]
Config.allowedClasses = {
    [0] = true,  -- Compacts
    [1] = true,  -- Sedans
    [2] = true,  -- SUVs
    [3] = true,  -- Coupes
    [4] = true,  -- Muscle
    [5] = true,  -- Sports Classics
    [6] = true,  -- Sports
    [7] = true,  -- Super
    [8] = true,  -- Motorcycles
    [9] = true,  -- Off-road
    [12] = true, -- Vans
    [17] = true, -- Service (táxi, etc.)
    [18] = true, -- Emergency
    [22] = true, -- Open Wheel
}

--- Modelos sem alavanca / sem animação (elétricos, etc.)
Config.blockedModels = {
    [`voltic`] = true,
    [`voltic2`] = true,
    [`tezeract`] = true,
    [`cyclone`] = true,
    [`raiden`] = true,
    [`neon`] = true,
    [`imorgon`] = true,
    [`iwagen`] = true,
    [`khamelion`] = true,
    [`dilettante`] = true,
    [`dilettante2`] = true,
    [`surge`] = true,
    [`caddy`] = true,
    [`caddy2`] = true,
    [`caddy3`] = true,
    [`airtug`] = true,
}

--- Braço / alavanca no carro (LHD). flag 48 = UPPERBODY (16) + ENABLE_PLAYER_CONTROL (32)
Config.Car = {
    enabled = true,
    dict = 'veh@driveby@first_person@passenger_rear_right_handed@smg',
    clip = 'outro_90r',
    duration = 650,
    flag = 48,
    blendIn = 8.0,
    blendOut = 8.0,
}

--[[
  Pé esquerdo na mota (classe 8).
  NÃO usar flag 48 (upperbody) — bloqueia o movimento das pernas.
  Candidatos tentados por ordem até um clip existir no build.
  Nunca fazer fallback para animação de mão de carro.
]]
Config.Bike = {
    enabled = true,
    duration = 450,
    flag = 32, -- ENABLE_PLAYER_CONTROL, corpo completo (pé visível)
    blendIn = 6.0,
    blendOut = 6.0,
    candidates = {
        { dict = 'veh@bike@dirt@front@base', clip = 'change_gear' },
        { dict = 'veh@bike@sport@ds@base', clip = 'change_gear' },
        { dict = 'veh@bike@sport@front@base', clip = 'change_gear' },
        { dict = 'veh@bike@cruiser@front@base', clip = 'change_gear' },
        { dict = 'veh@bike@quad@front@base', clip = 'change_gear' },
        { dict = 'veh@bike@common@front@base', clip = 'change_gear' },
        -- último recurso: tap do pé esquerdo (kick-start curto)
        { dict = 'veh@bike@dirt@front@base', clip = 'pov_start_engine', duration = 220 },
        { dict = 'veh@bike@dirt@front@base', clip = 'start_engine', duration = 220 },
    },
}
