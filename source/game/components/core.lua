--[[
    CORE COMPONENTS
    Universal components used by most entities.
    Add general-purpose components at the bottom of this file.

    Usage:
        local entity = Entity.new({
            transform = Transform(200, 120),
            velocity = Velocity(1, 0),
            health = Health(5),
        })
]]

-- Position and rotation in the world
function Transform(x, y, rotation)
    return {
        x = x or 0,
        y = y or 0,
        rotation = rotation or 0,
    }
end

-- Movement vector (used by PhysicsSystem)
function Velocity(dx, dy)
    return {
        dx = dx or 0,
        dy = dy or 0,
    }
end

-- Basic health / lives
function Health(hp)
    return {
        current = hp or 3,
        max = hp or 3,
    }
end
