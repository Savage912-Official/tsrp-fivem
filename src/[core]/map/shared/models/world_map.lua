-- Uses a 2d grid to spatially partition the map for storing things more efficiently.
WorldMap = {}

local CELL_SIZE       = 100
local NUM_CELLS       = 300
local WORLD_TRANSLATE = 15000

-- Forward declarations
local get_cell_xy,
      get_neighbors

local current

function WorldMap.find_objects(coords, label, range)
    local nearby = current:find_nearby_objects(coords, label, range)
    return nearby
end
exports("FindObjects", WorldMap.find_objects)

function WorldMap.start_tracking(coords, label, object)
    local x, y, z = table.unpack(coords)

    local x1 = string.format("%.2f", x)
    local y1 = string.format("%.2f", y)
    local z1 = string.format("%.2f", z)

    current:add_object(vector3(x1, y1, z1), label, object)
end
exports("StartTracking", WorldMap.start_tracking)

function WorldMap.stop_tracking(coords, label)
    local x, y, z = table.unpack(coords)

    local x1 = string.format("%.2f", x)
    local y1 = string.format("%.2f", y)
    local z1 = string.format("%.2f", z)

    current:remove_object(vector3(x1, y1, z1), label)
end
exports("StopTracking", WorldMap.stop_tracking)

function WorldMap.current()
    return current
end

function WorldMap.initialize()
    local cells = {}

    for x = 1, NUM_CELLS do
        cells[x] = {}

        for y = 1, NUM_CELLS do
            cells[x][y] = {}
        end
    end

    current = WorldMap:new({ cells = cells })

    return current
end

function WorldMap:new(o)
    o = o or {}

    setmetatable(o, self)
    self.__index = self

    return o
end

function WorldMap:add_object(coords, label, object)
    local cell, cx, cy = self:get_cell(coords)

    local storage = cell[label]

    if not storage then
        storage     = {}
        cell[label] = storage
    end

    -- TODO: We use coordinates as a primary key for now. Should be some kind of UUID probably.
    object.coords = coords
    table.insert(storage, object)

    TriggerEvent(Events.LOG_MESSAGE, {
        level   = Logging.DEBUG,
        message = "Added new map object labeled '" .. label .. "' at " .. cx .. ", " .. cy .. ": " .. tostring(object) .. "."
    })
end

-- Returns stored objects for the given label in the current map cell and all surrounding
-- cells (in case something is on a border).
function WorldMap:find_nearby_objects(coords, label, range)
    local cell, cx, cy = self:get_cell(coords)

    local neighbors = get_neighbors(self, cx, cy)
    local nearby    = {}

    for _, object in ipairs(cell[label] or {}) do
        if Vdist2(coords, object.coords) <= range then
            table.insert(nearby, object)
        end
    end

    for _, neighbor in ipairs(neighbors) do
        for _, object in ipairs(neighbor[label] or {}) do
            if Vdist2(coords, object.coords) <= range then
                table.insert(nearby, object)
            end
        end
    end

    return nearby
end

function WorldMap:get_cell(coords)
    local cx, cy = get_cell_xy(coords)
    return self.cells[cx][cy], cx, cy
end

function WorldMap:remove_object(coords, label)
    local cell, cx, cy = self:get_cell(coords)

    for i, object in ipairs(cell[label] or {}) do
        if object.coords == coords then
            table.remove(cell, i)

            TriggerEvent(Events.LOG_MESSAGE, {
                level   = Logging.DEBUG,
                message = "Removed map object labeled '" .. label .. "' at " .. cx .. ", " .. cy .. ": " .. tostring(object) .. "."
            })

            return true
        end
    end

    return false
end

-- @local
function get_cell_xy(coords)
    -- use math.ceil() b/c Lua list in self.cells starts at index 1
    local cell_x = math.ceil((coords.x + WORLD_TRANSLATE) / CELL_SIZE)
    local cell_y = math.ceil((coords.y + WORLD_TRANSLATE) / CELL_SIZE)

    return cell_x, cell_y
end

-- @local
function get_neighbors(map, x, y)
    local neighbors = {}

    if y > 1 then
        table.insert(neighbors, map.cells[x][y - 1])

        if x < NUM_CELLS then table.insert(neighbors, map.cells[x + 1][y - 1]) end
        if x > 1 then table.insert(neighbors, map.cells[x - 1][y - 1]) end
    end

    if x > 1 then
        table.insert(neighbors, map.cells[x - 1][y])
        if y < NUM_CELLS then table.insert(neighbors, map.cells[x - 1][y + 1]) end
    end

    if y < NUM_CELLS then
        table.insert(neighbors, map.cells[x][y + 1])
        if x < NUM_CELLS then table.insert(neighbors, map.cells[x + 1][y + 1]) end
    end

    if x < NUM_CELLS then table.insert(neighbors, map.cells[x + 1][y]) end

    return neighbors
end
