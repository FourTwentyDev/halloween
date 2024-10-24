local JumpscareConfig = {
    npcModel = "u_m_y_zombie_01",
    spawnDistance = 10.0,
    duration = 3000,
    fogDensity = 0.3,
    jumpscareChance = 0.1,
    runSpeed = 8.0
}

local ScarySound = {
    {"GROWL_LOW", "ANIMALS_HAWK_SCREECH_MASTER"},
    {"DISTANT_DOG_BARK_MASTER", "ANIMALS_DOG_BARK_MASTER"},
    {"GROWL", "ANIMALS_MOUNTAIN_LION_MASTER"},
    {"SCREECH", "ANIMALS_HAWK_SCREECH_MASTER"},
    {"BARK", "ANIMALS_DOG_BARK_PANIC_MASTER"},
    {"DEATH_SCREAM", "PAPARAZZO_03_SOUNDS"}
}

local animDict = "amb@prop_human_parking_meter@male@idle_a"
local animName = "idle_a"

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
    end
end

local function GetSpawnPositionInFOV(playerPos, playerHeading)
    local fovOffset = math.random(-60, 60)
    local finalHeading = math.rad(playerHeading + fovOffset)
    
    local spawnPos = vector3(
        playerPos.x + math.cos(finalHeading) * JumpscareConfig.spawnDistance,
        playerPos.y + math.sin(finalHeading) * JumpscareConfig.spawnDistance,
        playerPos.z
    )
    
    local groundZ = 0.0
    local found, z = GetGroundZFor_3dCoord(spawnPos.x, spawnPos.y, spawnPos.z + 2.0, groundZ, false)
    if found then
        spawnPos = vector3(spawnPos.x, spawnPos.y, z)
    end
    
    return spawnPos
end

local function CreateFogEffect(playerPos)
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
        Citizen.Wait(10)
    end
    
    UseParticleFxAssetNextCall("core")
    local fogHandle = StartParticleFxLoopedAtCoord(
        "exp_grd_bzgas_smoke",
        playerPos.x, playerPos.y, playerPos.z - 0.5,
        0.0, 0.0, 0.0,
        5.0,
        false, false, false, false
    )
    
    return fogHandle
end

local function SpawnJumpscareNPC(playerPos, playerHeading)
    local spawnPos = GetSpawnPositionInFOV(playerPos, playerHeading)
    
    RequestModel(GetHashKey(JumpscareConfig.npcModel))
    while not HasModelLoaded(GetHashKey(JumpscareConfig.npcModel)) do
        Citizen.Wait(10)
    end
    
    local npcPed = CreatePed(4, GetHashKey(JumpscareConfig.npcModel), 
        spawnPos.x, spawnPos.y, spawnPos.z, 
        playerHeading, false, true)
    
    SetEntityInvincible(npcPed, true)
    SetBlockingOfNonTemporaryEvents(npcPed, true)
    
    RequestAnimDict("move_m@injured")
    while not HasAnimDictLoaded("move_m@injured") do
        Citizen.Wait(10)
    end
    StopPedSpeaking(npcPed, true)
    TaskPlayAnim(npcPed, "move_m@injured", "run", 8.0, -8.0, -1, 1, 0, false, false, false)
    
    return npcPed
end

local function MakeNPCChasePlayer(npcPed, playerPed)
    Citizen.CreateThread(function()
        local startTime = GetGameTimer()
        
        while GetGameTimer() - startTime < JumpscareConfig.duration do
            local playerPos = GetEntityCoords(playerPed)
            TaskGoToEntity(npcPed, playerPed, -1, 0.0, JumpscareConfig.runSpeed, 1073741824, 0)
            SetPedMoveRateOverride(npcPed, JumpscareConfig.runSpeed)
            Citizen.Wait(100)
        end
    end)
end

local function TriggerJumpscare()
    if math.random() > JumpscareConfig.jumpscareChance then
        return
    end
    
    local playerPed = PlayerPedId()
    local playerPos = GetEntityCoords(playerPed)
    local playerHeading = GetEntityHeading(playerPed)
    
    AnimpostfxPlay("DeathFailOut", 0, false)
    ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.3)
    
    local fogHandle = CreateFogEffect(playerPos)
    
    local randomSound = ScarySound[math.random(#ScarySound)]
    PlaySoundFrontend(-1, randomSound[1], randomSound[2], true)
    
    for i = 1, 10, 1 do
        Citizen.SetTimeout(300, function()
            PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", true)
        end)
        Citizen.Wait(300)
    end

    local npcPed = SpawnJumpscareNPC(playerPos, playerHeading)
    MakeNPCChasePlayer(npcPed, playerPed)
    
    Citizen.SetTimeout(JumpscareConfig.duration, function()
        AnimpostfxStop("DeathFailOut")
        StopParticleFxLooped(fogHandle, 0)
        DeleteEntity(npcPed)
        PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", true)
    end)
end

local function PlayPumpkinAnimation()
    local playerPed = PlayerPedId()
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do
        Citizen.Wait(10)
    end
    
    TaskPlayAnim(playerPed, animDict, animName, 8.0, -8.0, -1, 0, 0, false, false, false)
    Citizen.Wait(2500)
    ClearPedTasks(playerPed)
    
    RemoveAnimDict(animDict)
end

local function PlayPumpkinSound()
    PlaySoundFrontend(-1, "WEAPON_PURCHASE", "HUD_AMMO_SHOP_SOUNDSET", 1)
    TriggerJumpscare()
    Citizen.Wait(100)
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", 1)
    
    if math.random() > 0.7 then
        Citizen.Wait(200)
        PlaySoundFrontend(-1, "SPOOKY_FOOTSTEP_3", "HALLOWEEN_SOUNDS", 1)
    end
end

RegisterNetEvent('halloween:syncPumpkins')
AddEventHandler('halloween:syncPumpkins', function(pumpkinStates)
    for _, prop in pairs(Client.activeProps) do
        if DoesEntityExist(prop.entity) then
            DeleteObject(prop.entity)
        end
    end
    Client.activeProps = {}
    
    for index, state in pairs(pumpkinStates) do
        if state.active then
            local coords = Config.PumpkinLocations[index]
            local pumpkin = CreateObject(GetHashKey("prop_veg_crop_03_pump"), coords.x, coords.y, coords.z - 1.0, false, false, false)
            PlaceObjectOnGroundProperly(pumpkin)
            Client.activeProps[index] = {
                entity = pumpkin,
                coords = coords
            }
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        interval = 1000
        local playerPos = GetEntityCoords(PlayerPedId())
        
        for index, propData in pairs(Client.activeProps) do
            if DoesEntityExist(propData.entity) then
                local dist = #(playerPos - vector3(propData.coords.x, propData.coords.y, propData.coords.z))
                
                if dist < Config.SearchRadius then
                    interval = 0
                    local objectCoords = GetEntityCoords(propData.entity)
                    DrawText3D(objectCoords.x, objectCoords.y, objectCoords.z + 1.0, _('press_collect_pumpkin'))
                    
                    if IsControlJustPressed(0, Config.CollectKey) then
                        PlayPumpkinAnimation()
                        PlayPumpkinSound()
                        
                        local coords = GetEntityCoords(propData.entity)
                        RequestNamedPtfxAsset("core")
                        while not HasNamedPtfxAssetLoaded("core") do
                            Citizen.Wait(10)
                        end
                        UseParticleFxAssetNextCall("core")
                        StartParticleFxNonLoopedAtCoord("ent_dst_gen_gobstop", 
                            coords.x, coords.y, coords.z + 0.5, 
                            0.0, 0.0, 0.0, 
                            0.8, false, false, false)
                        
                        TriggerServerEvent('halloween:collectPumpkin', index)
                    end
                end
            end
        end
        Citizen.Wait(interval)
    end
end)
