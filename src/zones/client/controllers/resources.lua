local function create(resource_name)
    if GetCurrentResourceName() ~= resource_name then return end
    TriggerServerEvent(Events.GET_ZONES)
    Zone.setup()
end
AddEventHandler(Events.ON_CLIENT_RESOURCE_START, create)
