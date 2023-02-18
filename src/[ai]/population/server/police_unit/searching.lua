Searching = {}

PoliceUnit.States[PoliceStates.SEARCHING] = Searching

-- Forward declarations
local sync_task

function Searching:new(o)
    o = o or {}

    setmetatable(o, self)
    self.__index = self

    return o
end

function Searching:enter()
    sync_task(self)
end

function Searching:exit()
end

function Searching:update()
    if not self.unit.assigned_call then
        self.unit:move_to(PoliceStates.AVAILABLE)
        return
    end

    if GetPedScriptTaskCommand(self.unit.entity) == Tasks.NO_TASK then
        sync_task(self)
    end
end

-- @local
function sync_task(search)
    local owner = NetworkGetEntityOwner(search.unit.entity)

    TriggerClientEvent(Events.CREATE_POPULATION_TASK, owner, {
        net_id   = NetworkGetNetworkIdFromEntity(search.unit.entity),
        location = search.unit.assigned_call.location,
        task_id  = Tasks.SEARCH_FOR_HATED_IN_AREA
    })
end