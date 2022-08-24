WebSerializer = {}

-- Forward declarations
local serialize_component, serialize_models

function WebSerializer:new(o)
    o = o or {}

    setmetatable(o, self)
    self.__index = self

    return o
end

-- Serialize the ped into a format that can be used to initialize the web UI.
function WebSerializer:serialize()
    local attributes = {}

    for name, details in pairs(Attributes) do
        if details.type == AttributeTypes.COMPONENT then
            local component = serialize_component(self.ped, name)

            if component then
                table.insert(attributes, component)
            end
        elseif details.type == AttributeTypes.MODEL then
            table.insert(attributes, serialize_models(self.ped, name))
        end
    end

    return {
        categories = attributes
    }
end

-- @local
function serialize_component(ped, name)
    local attribute        = Attributes[name]
    local draw_count       = GetNumberOfPedDrawableVariations(ped, attribute.index)
    local current_drawable = GetPedDrawableVariation(ped, attribute.index)
    local current_texture  = GetPedTextureVariation(ped, attribute.index)
    local texture_count    = GetNumberOfPedTextureVariations(ped, attribute.index, current_drawable)

    return {
        label    = attribute.label,
        name     = name,
        controls = {
            {
                type  = "index",
                label = "Style",
                value = current_drawable + 1, -- 1-based indices in the UI
                count = draw_count
            },
            {
                type  = "slider",
                label = "Variant",
                value = current_texture + 1,
                min   = 1,
                max   = texture_count
            }
        }
    }
end

-- @local
function serialize_models(ped, name)
    local attribute = Attributes[name]
    local model     = GetEntityModel(ped)
    local index     = -1

    for i, m in ipairs(PedModels) do
        if GetHashKey(m) == model then
            index = i
            break
        end
    end

    return {
        label = attribute.label,
        name  = name,
        controls = {
            {
                type  = "index",
                label = "Model",
                value = index,
                count = #PedModels
            }
        }
    }
end
