--[[
    ENTITY
    An entity is just a table with an ID and component data as named fields.

    Usage:
        local player = Entity.new({
            transform = Transform(200, 120),
            velocity = Velocity(0, 0),
            playerInput = PlayerInput(),
        })

        -- Add a component later
        player.health = Health(3)

        -- Check if entity has a component
        if player.health then ... end

        -- Remove a component
        player.health = nil

        -- Destroy (removed at end of frame)
        player.active = false
]]

Entity = {}
Entity._nextId = 0

function Entity.new(components)
    Entity._nextId += 1
    local entity = {
        id = Entity._nextId,
        active = true,
    }
    if components then
        for k, v in pairs(components) do
            entity[k] = v
        end
    end
    return entity
end
