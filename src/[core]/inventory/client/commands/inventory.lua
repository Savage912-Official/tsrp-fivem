local function cmd_inventory(_, _, _)
    if IsPedDeadOrDying(PlayerPedId(), 1) then return end

    TriggerServerEvent(Events.CREATE_INVENTORY_REFRESH)

    TriggerEvent(Events.CREATE_INVENTORY_SESSION, {
        inventory = {}
    })
end
RegisterCommand("inventory", cmd_inventory, false)
RegisterKeyMapping("inventory", "Inventory", "keyboard", "i")
