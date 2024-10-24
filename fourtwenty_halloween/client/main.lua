ESX = exports["es_extended"]:getSharedObject()

Client = {
    activeProps = {},
    visitedDoors = {}
}

Citizen.CreateThread(function()
    TriggerServerEvent('halloween:requestSync')
end)