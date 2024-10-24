ESX = exports["es_extended"]:getSharedObject()

Server = {
    pumpkinStates = {},
    doorStates = {},
    playerDoorStates = {},
    
    Initialize = function(self)
        for i = 1, #Config.PumpkinLocations do
            self.pumpkinStates[i] = {
                active = true,
                respawnTime = 0
            }
        end
        
        for i = 1, #Config.DoorLocations do
            self.doorStates[i] = false
        end
    end,
    
    GetRandomReward = function(self, rewardTable)
        local rand = math.random(1, 100)
        local currentProb = 0
        
        for _, reward in ipairs(rewardTable) do
            currentProb = currentProb + reward.chance
            if rand <= currentProb then
                local amount = math.random(reward.amount[1], reward.amount[2])
                return {item = reward.item, amount = amount}
            end
        end
        return nil
    end
}

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    Server:Initialize()
end)