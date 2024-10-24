ESX = exports["es_extended"]:getSharedObject()

Client = {
    visitedDoors = {},
    activeProps = {}
}

local knockAnimDict = "timetable@jimmy@doorknock@"
local knockAnimName = "knockdoor_idle"

local function PlayKnockAnimation()
    local playerPed = PlayerPedId()
    
    RequestAnimDict(knockAnimDict)
    while not HasAnimDictLoaded(knockAnimDict) do
        Citizen.Wait(10)
    end
    
    TaskPlayAnim(playerPed, knockAnimDict, knockAnimName, 8.0, -8.0, -1, 0, 0, false, false, false)
    
    Citizen.Wait(300)
    PlaySoundFromEntity(-1, "DOOR_KNOCK", playerPed, "SASQUATCH_03_SOUNDS", true, 0)
    Citizen.Wait(500)
    PlaySoundFromEntity(-1, "DOOR_KNOCK", playerPed, "SASQUATCH_03_SOUNDS", true, 0)
    Citizen.Wait(500)
    PlaySoundFromEntity(-1, "DOOR_KNOCK", playerPed, "SASQUATCH_03_SOUNDS", true, 0)
    
    Citizen.Wait(1000)
    
    local phrases = {
        "GENERIC_EXCITED_EVENT",
        "GENERIC_THANKS",
        "GENERIC_THANKS_FEMALE",
        "GENERIC_SHOCKED_HIGH"
    }
    PlayAmbientSpeech1(playerPed, phrases[math.random(#phrases)], "SPEECH_PARAMS_FORCE_SHOUTED")
    
    Citizen.Wait(500)
    ClearPedTasks(playerPed)
    
    RemoveAnimDict(knockAnimDict)
end

RegisterNetEvent('halloween:syncDoors')
AddEventHandler('halloween:syncDoors', function(doorStates)
    Client.visitedDoors = doorStates
end)

RegisterNetEvent('halloween:trickOrTreatSuccess')
AddEventHandler('halloween:trickOrTreatSuccess', function(reward)
    PlaySoundFrontend(-1, "WEAPON_PURCHASE", "HUD_AMMO_SHOP_SOUNDSET", 1)
    
    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
        Citizen.Wait(10)
    end
    UseParticleFxAssetNextCall("core")
    StartParticleFxNonLoopedAtCoord("ent_dst_gen_gobstop", 
        coords.x, coords.y, coords.z + 1.0, 
        0.0, 0.0, 0.0, 
        1.0, false, false, false)
end)

Citizen.CreateThread(function()
    TriggerServerEvent('halloween:requestSync')
    
    while true do
        Citizen.Wait(0)
        local playerPed = PlayerPedId()
        local playerPos = GetEntityCoords(playerPed)
        
        for index, coords in ipairs(Config.DoorLocations) do
            if not Client.visitedDoors[index] then
                local dist = #(playerPos - vector3(coords.x, coords.y, coords.z))
                
                if dist < Config.SearchRadius then
                    DrawText3D(coords.x, coords.y, coords.z + 1.0, _("press_trick_or_treat"))
                    
                    if IsControlJustPressed(0, Config.CollectKey) and not IsEntityPlayingAnim(playerPed, knockAnimDict, knockAnimName, 3) then
                        PlayKnockAnimation()
                        TriggerServerEvent('halloween:trickOrTreat', index)
                    end
                end
            end
        end
    end
end)
