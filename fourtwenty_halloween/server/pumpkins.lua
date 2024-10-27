ESX = exports["es_extended"]:getSharedObject()

-- Pfad zur JSON-Datei
local PUMPKIN_STATS_FILE = "./pumpkin_stats.json"

-- Einfache Statistik-Struktur
local PumpkinStats = {
    players = {} -- Speichert {identifier = {name = name, count = anzahl}}
}

-- Hilfsfunktionen für JSON-Dateioperationen
local function loadJsonFile()
    local file = io.open(PUMPKIN_STATS_FILE, "r")
    if not file then return false end
    
    local content = file:read("*all")
    file:close()
    
    local success, data = pcall(json.decode, content)
    if success then
        PumpkinStats = data
    end
end

local function saveJsonFile()
    local file = io.open(PUMPKIN_STATS_FILE, "w")
    if not file then return false end
    
    local success, content = pcall(json.encode, PumpkinStats)
    if success then
        file:write(content)
    end
    file:close()
end

Citizen.CreateThread(function()
    loadJsonFile()
end)

RegisterNetEvent('halloween:collectPumpkin')
AddEventHandler('halloween:collectPumpkin', function(index)
    local xPlayer = ESX.GetPlayerFromId(source)
    if not xPlayer then return end
    
    if Server.pumpkinStates[index] and Server.pumpkinStates[index].active then
        Server.pumpkinStates[index].active = false
        Server.pumpkinStates[index].respawnTime = os.time() + (Config.RespawnTime * 60)
        
        local reward = Server:GetRandomReward(Config.Rewards.pumpkins)
        if reward then
            xPlayer.addInventoryItem(reward.item, reward.amount)
            
            local playerIdentifier = xPlayer.identifier
            if not PumpkinStats.players[playerIdentifier] then
                PumpkinStats.players[playerIdentifier] = {
                    name = xPlayer.getName(),
                    count = 0
                }
            end
            PumpkinStats.players[playerIdentifier].count = PumpkinStats.players[playerIdentifier].count + 1
            

            saveJsonFile()
            Notify(xPlayer, _('pumpkin_collected', reward.amount, reward.item))
        end
        
        TriggerClientEvent('halloween:syncPumpkins', -1, Server.pumpkinStates)
    end
end)

ESX.RegisterCommand('pumpkinleader', 'user', function(xPlayer, args, showError)

    local sortedPlayers = {}
    for identifier, data in pairs(PumpkinStats.players) do
        table.insert(sortedPlayers, {
            name = data.name,
            count = data.count
        })
    end
    
    table.sort(sortedPlayers, function(a, b)
        return a.count > b.count
    end)
    
 
    TriggerClientEvent('chat:addMessage', xPlayer.source, {
        color = {255, 128, 0},
        multiline = true,
        args = {'🎃 Leaderboard 🎃'}
    })
    
    for i = 1, math.min(10, #sortedPlayers) do
        local player = sortedPlayers[i]
        TriggerClientEvent('chat:addMessage', xPlayer.source, {
            color = {255, 165, 0},
            args = {string.format('#%d - %s: %d 🎃', i, player.name, player.count)}
        })
    end
end, false)


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(300000) 
        saveJsonFile()
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(20000) 
        local currentTime = os.time()
        local changed = false
        
        for index, state in pairs(Server.pumpkinStates) do
            if not state.active and state.respawnTime > 0 and currentTime >= state.respawnTime then
                state.active = true
                state.respawnTime = 0
                changed = true
            end
        end
        
        if changed then
            TriggerClientEvent('halloween:syncPumpkins', -1, Server.pumpkinStates)
        end
    end
end)