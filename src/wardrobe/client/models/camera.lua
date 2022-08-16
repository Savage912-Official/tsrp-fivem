Camera = {}

function Camera:new(o)
    o = o or {}

    setmetatable(o, self)
    self.__index = self

    return o
end

function Camera:cleanup()
    SetCamActive(self.camera, false)
    RenderScriptCams(false, true, 1500, true, true)
end

function Camera:get_location()
    return GetCamCoord(self.camera)
end

function Camera:get_matrix()
    return GetCamMatrix(self.camera)
end

function Camera:initialize()
    local cloc = GetGameplayCamCoord()
    local ploc = GetEntityCoords(PlayerPedId())
    local spot = ploc - (norm(ploc - cloc) * 2)

    self.camera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", spot.x, spot.y, ploc.z + 0.2, 0, 0, 0, 65.0, false, 0)

    SetCamUseShallowDofMode(self.camera, true)
    SetCamNearDof(self.camera, 0.5)
    SetCamFarDof(self.camera, 4.0)
    SetCamDofStrength(self.camera, 1.0)
    PointCamAtEntity(self.camera, PlayerPedId(), -0.9, 0, 0, 1)
    SetCamActive(self.camera, true)
    RenderScriptCams(true, true, 1500, true, true)
end

-- Called every frame while wardrobe session is active
function Camera:update()
    SetUseHiDof() -- enables camera depth of field
end
