--[[
    COLLISION COMPONENTS
    Components related to collision detection and physics boundaries.
    Add new collision-related components at the bottom of this file.

    Usage:
        local entity = Entity.new({
            transform = Transform(100, 50),
            collider = Collider(16, 16),
        })

    Groups let you control what collides with what.
    For example, group 1 = player, group 2 = enemies, group 3 = projectiles.
]]

-- Collision bounds (used by CollisionSystem)
function Collider(width, height, group)
    return {
        width = width or 16,
        height = height or 16,
        group = group or 1,
    }
end
