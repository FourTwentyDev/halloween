ESX = exports["es_extended"]:getSharedObject()
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    if not Server.playerDoorStates[playerId] then
        Server.playerDoorStates[playerId] = {}
        for i = 1, #Config.DoorLocations do
            Server.playerDoorStates[playerId][i] = false
        end
    end
end)

AddEventHandler('playerDropped', function()
    local playerId = source
    if Server.playerDoorStates[playerId] then
        Server.playerDoorStates[playerId] = nil
    end
end)

RegisterNetEvent('halloween:trickOrTreat')
AddEventHandler('halloween:trickOrTreat', function(index)
    local playerId = source
    local xPlayer = ESX.GetPlayerFromId(playerId)
    if not xPlayer then return end
    
    if not Server.playerDoorStates[playerId] then
        Server.playerDoorStates[playerId] = {}
        for i = 1, #Config.DoorLocations do
            Server.playerDoorStates[playerId][i] = false
        end
    end
    

    if not Server.playerDoorStates[playerId][index] then
        Server.playerDoorStates[playerId][index] = true
        
        local reward = Server:GetRandomReward(Config.Rewards.trickortreat)
        if reward then
            xPlayer.addInventoryItem(reward.item, reward.amount)
            TriggerClientEvent('halloween:trickOrTreatSuccess', playerId, reward)
            Notify(xPlayer, _('trick_or_treat_success', reward.amount, reward.item))
        end
        

        TriggerClientEvent('halloween:syncDoors', playerId, Server.playerDoorStates[playerId])
    end
end)

RegisterNetEvent('halloween:requestSync')
AddEventHandler('halloween:requestSync', function()
    local playerId = source

    if not Server.playerDoorStates[playerId] then
        Server.playerDoorStates[playerId] = {}
        for i = 1, #Config.DoorLocations do
            Server.playerDoorStates[playerId][i] = false
        end
    end
    

    TriggerClientEvent('halloween:syncPumpkins', source, Server.pumpkinStates)
    TriggerClientEvent('halloween:syncDoors', playerId, Server.playerDoorStates[playerId])
end)