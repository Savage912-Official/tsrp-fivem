PoliceUnit = {}

PoliceUnit.States = {}

-- Forward declarations
local start_updates

local all_units = {}
local is_active = false

function PoliceUnit.closest(coords)
    local closest  = nil
    local distance = nil

    local d

    for _, unit in ipairs(all_units) do
        d = Dist2d(GetEntityCoords(unit.entity), coords)

        if not distance or d < distance then
            distance = d
            closest  = unit
        end
    end

    return closest, distance
end

function PoliceUnit.for_entity(entity)
    for _, unit in ipairs(all_units) do
        if unit.entity == entity then
            return unit
        end
    end

    return nil
end

function PoliceUnit.available_nearby(coords, range)
    local results = {}

    for _, unit in ipairs(all_units) do
        if not unit.assigned_call and Dist2d(GetEntityCoords(unit.entity), coords) < range then
            table.insert(results, unit)
        end
    end

    return results
end

function PoliceUnit:new(o)
    o = o or {}

    setmetatable(o, self)
    self.__index = self

    return o
end

function PoliceUnit:assign_call(call)
    self.assigned_call = call

    self:move_to(PoliceStates.RESPONDING)

    local descriptor = "Police unit " .. self.entity
    local vehicle    = GetVehiclePedIsIn(self.entity, false)

    if vehicle > 0 then
        descriptor = descriptor .. " in vehicle " .. vehicle
    end

    Logging.log(Logging.INFO, descriptor .. " assigned call " .. call.id .. " at " .. call.location .. ".")
end

function PoliceUnit:clear()
    if not self.assigned_call then return end

    local id = self.assigned_call.id

    self.assigned_call  = nil
    self.current_target = nil

    if DoesEntityExist(self.entity) then
        self:move_to(PoliceStates.AVAILABLE)
    end

    Logging.log(Logging.INFO, "Police unit " .. self.entity .. " cleared call " .. id .. ".")
end

function PoliceUnit:initialize()
    table.insert(all_units, self)

    self:move_to(PoliceStates.AVAILABLE)

    Logging.log(Logging.DEBUG, "Now tracking " .. #all_units .. " police units.")

    if not is_active then
        start_updates()
    end
end

function PoliceUnit:move_to(state_id)
    if self.state_id == state_id then return end
    self.state_id = state_id

    if self.state then
        self.state:exit()
    end

    local constructor = PoliceUnit.States[state_id]

    self.state = constructor:new({
        created_at = GetGameTimer(),
        unit       = self,
    })

    self.state:enter()

    Logging.log(Logging.TRACE, "Police unit " .. self.entity .. " moved to state " .. PoliceStates.LABELS[state_id] .. ".")
end

function PoliceUnit:process_input(data)
    if data.task_id == Tasks.OBSERVE_THREAT then
        self.current_target = NetworkGetEntityFromNetworkId(data.threat)
        self:move_to(PoliceStates.FIGHTING)
    elseif self.state.process_input then
        self.state:process_input(data)
    else
        Logging.log(Logging.WARN, "No input handling for task " .. data.task_id .. " on state " .. self.state_id .. ".")
    end
end

function PoliceUnit:update()
    -- TODO: Assign the closest suspect
    if self.assigned_call and not self.current_target and #self.assigned_call.suspects > 0 then
        self.current_target = self.assigned_call.suspects[1]
    end

    if self.state then
        self.state:update()
    end
end

-- @local
function start_updates()
    is_active = true

    Logging.log(Logging.DEBUG, "Starting police unit updates.")

    Citizen.CreateThread(function()
        while is_active do
            for i = #all_units, 1, -1 do
                local unit = all_units[i]

                if DoesEntityExist(unit.entity) then
                    unit:update()
                else
                    unit:clear()
                    table.remove(all_units, i)
                    Logging.log(Logging.DEBUG, "Now tracking " .. #all_units .. " police units.")
                end
            end

            if #all_units == 0 then
                is_active = false
                break
            end

            Citizen.Wait(3000)
        end

        Logging.log(Logging.DEBUG, "Stopping police unit updates.")
    end)
end
