Confronting = {}

PoliceUnit.States[PoliceStates.CONFRONTING] = Confronting

-- Forward declarations
local sync_task

function Confronting:new(o)
    o = o or {}

    setmetatable(o, self)
    self.__index = self

    return o
end

function Confronting:enter()
    sync_task(self)
end

function Confronting:exit()
end

function Confronting:update()
    if not self.unit.assigned_call then
        self.unit:move_to(PoliceStates.AVAILABLE)
        return
    end

    if not DoesEntityExist(self.unit.current_target) or Dist2d(GetEntityCoords(self.unit.current_target), GetEntityCoords(self.unit.entity)) > 20.0 then
        self.unit:move_to(PoliceStates.SEARCHING)
        return
    end

    if GetPedScriptTaskCommand(self.unit.entity) == Tasks.NO_TASK then
        sync_task(self)
    end
end

-- @local
function sync_task(confrontation)
    local owner = NetworkGetEntityOwner(confrontation.unit.entity)

    TriggerClientEvent(Events.CREATE_POPULATION_TASK, owner, {
        net_id  = NetworkGetNetworkIdFromEntity(confrontation.unit.entity),
        target  = NetworkGetNetworkIdFromEntity(confrontation.unit.current_target),
        task_id = Tasks.AIM_AT_ENTITY
    })
end
