--[[
    PHYSICS SYSTEM
    Applies velocity to transform positions each frame.

    ── Notes ─────────────────────────────────────────────

    Playdate runs at 30 FPS by default.
    You can change it: playdate.display.setRefreshRate(fps)
    Check it: playdate.display.getRefreshRate()

    Screen bounds: 400 x 240 pixels (use SCREEN_WIDTH, SCREEN_HEIGHT)

    Common patterns:
        -- Friction (multiply velocity each frame to slow down)
        velocity.dx *= 0.95
        velocity.dy *= 0.95

        -- Gravity (add to vertical velocity each frame)
        velocity.dy += 0.5

        -- Screen wrapping
        if transform.x > SCREEN_WIDTH then transform.x = 0 end
        if transform.x < 0 then transform.x = SCREEN_WIDTH end

        -- Screen clamping
        transform.x = clamp(transform.x, 0, SCREEN_WIDTH)
        transform.y = clamp(transform.y, 0, SCREEN_HEIGHT)

        -- Bounce off walls
        if transform.x <= 0 or transform.x >= SCREEN_WIDTH then
            velocity.dx = -velocity.dx
        end

    Math helpers:
        math.sqrt, math.sin, math.cos, math.atan(y, x)
        math.abs, math.floor, math.ceil, math.rad, math.deg
        math.max, math.min, math.random(min, max)

    Utility functions (from lib/utils.lua):
        clamp(val, min, max)
        lerp(a, b, t)
        distance(x1, y1, x2, y2)
        random_float(min, max)

    ──────────────────────────────────────────────────────
]]

PhysicsSystem = System.new("physics", {"transform", "velocity"}, function(entities, scene)
    for _, e in ipairs(entities) do
        local t = e.transform
        local v = e.velocity

        -- Apply velocity to position
        t.x += v.dx
        t.y += v.dy

        -- TODO: Add friction, gravity, screen bounds as needed
        -- v.dx *= 0.98
        -- v.dy *= 0.98
        -- t.x = clamp(t.x, 0, SCREEN_WIDTH)
        -- t.y = clamp(t.y, 0, SCREEN_HEIGHT)
    end
end)
