--[[
    INPUT COMPONENTS
    Components related to player input (buttons, crank, accelerometer).
    Add new input-related components at the bottom of this file.

    Usage:
        local player = Entity.new({
            transform = Transform(200, 120),
            playerInput = PlayerInput(3),
            crankInput = CrankInput(),
        })
]]

-- Marks an entity as controlled by buttons / d-pad (used by PlayerSystem)
function PlayerInput(speed)
    return {
        speed = speed or 2,
    }
end

-- Marks an entity as controlled by the crank (used by CrankSystem)
function CrankInput()
    return {
        angle = 0,          -- current crank position (0-360)
        change = 0,         -- degrees changed this frame
    }
end
