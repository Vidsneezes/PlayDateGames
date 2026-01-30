--[[
    COMPONENTS
    Each component is a constructor that returns a plain data table.
    Components hold DATA only -- no behavior, no methods.
    Systems read and modify component data.

    Usage:
        local player = Entity.new({
            transform = Transform(200, 120),
            velocity = Velocity(0, 0),
            playerInput = PlayerInput(),
            sprite = SpriteComp(myImage),
            collider = Collider(16, 16),
        })

    Adding new components:
        Just add a new function at the bottom of this file.
        Then use it when creating entities in your scene file.
]]

-- Position and rotation in the world
function Transform(x, y, rotation)
    return {
        x = x or 0,
        y = y or 0,
        rotation = rotation or 0,
    }
end

-- Movement vector
function Velocity(dx, dy)
    return {
        dx = dx or 0,
        dy = dy or 0,
    }
end

-- Visual representation
function SpriteComp(image)
    return {
        image = image,      -- a playdate.graphics.image
        visible = true,
    }
end

-- Marks an entity as controlled by buttons/d-pad
function PlayerInput(speed)
    return {
        speed = speed or 2,
    }
end

-- Marks an entity as controlled by the crank
function CrankInput()
    return {
        angle = 0,          -- current crank position (0-360)
        change = 0,         -- degrees changed this frame
    }
end

-- Collision bounds
function Collider(width, height, group)
    return {
        width = width or 16,
        height = height or 16,
        group = group or 1,
    }
end

-- Sound attached to an entity
function AudioSource(player)
    return {
        player = player,    -- a sampleplayer or fileplayer instance
        shouldPlay = false, -- set to true to trigger playback
    }
end

-- Basic health/lives
function Health(hp)
    return {
        current = hp or 3,
        max = hp or 3,
    }
end
