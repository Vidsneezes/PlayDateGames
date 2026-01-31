--[[
    BOID SYSTEM
    Controls boid movement based on emotional component type.

    Happy boids → move toward world center
    Sad boids   → move toward nearest world edge
    Angry boids → move toward closest non-angry boid

    Each emotion component has its own parameters (speed, detection range, etc.)

    ── Playdate SDK Quick Reference ──────────────────────

    Math functions:
        math.sqrt(x)                -- square root
        math.abs(x)                 -- absolute value
        math.min(a, b)              -- minimum of two values
        math.max(a, b)              -- maximum of two values

    Utility functions (from lib/utils.lua):
        distance(x1, y1, x2, y2)    -- Euclidean distance
        clamp(val, min, max)        -- clamp value to range

    ──────────────────────────────────────────────────────
]]

-- Helper: Normalize a vector and apply speed
local function normalize(dx, dy, speed)
    local len = math.sqrt(dx * dx + dy * dy)
    if len > 0 then
        return (dx / len) * speed, (dy / len) * speed
    end
    return 0, 0
end

-- BoidSystem processes entities with transform and velocity
-- It checks for emotion components and applies appropriate behaviors
BoidSystem = System.new("boid", {"transform", "velocity", "boidsprite"}, function(entities, scene)
    for _, e in ipairs(entities) do
        local t = e.transform
        local v = e.velocity
        local s = e.boidsprite

        -- Handle Happy Boids
        if e.happyBoid then
            local happy = e.happyBoid
            -- Move toward world center
            local worldW = scene.camera and scene.camera.worldWidth or WORLD_WIDTH
            local worldH = scene.camera and scene.camera.worldHeight or WORLD_HEIGHT
            local targetX = worldW / 2
            local targetY = worldH / 2
            local dx = targetX - t.x
            local dy = targetY - t.y

            -- Stop if close enough to target (within 3 pixels)
            local distToTarget = math.sqrt(dx * dx + dy * dy)
            if distToTarget < 3 then
                v.dx, v.dy = 0, 0
            else
                v.dx, v.dy = normalize(dx, dy, happy.speed)
            end

        -- Handle Sad Boids
        elseif e.sadBoid then
            local sad = e.sadBoid
            -- Move toward nearest world edge (but keep full sprite visible)
            local worldW = scene.camera and scene.camera.worldWidth or WORLD_WIDTH
            local worldH = scene.camera and scene.camera.worldHeight or WORLD_HEIGHT
            local spriteSize = 16  -- sprite is 16x16 pixels

            -- Distance to each edge (accounting for sprite size)
            local distLeft = t.x - 0  -- left edge target is 0
            local distRight = (worldW - spriteSize) - t.x  -- right edge target keeps sprite in bounds
            local distTop = t.y - 0  -- top edge target is 0
            local distBottom = (worldH - spriteSize) - t.y  -- bottom edge target keeps sprite in bounds

            -- Find closest edge
            local minDist = math.min(distLeft, distRight, distTop, distBottom)
            local targetX, targetY

            if minDist == distLeft then
                targetX, targetY = 0, t.y
            elseif minDist == distRight then
                targetX, targetY = worldW - spriteSize, t.y
            elseif minDist == distTop then
                targetX, targetY = t.x, 0
            else
                targetX, targetY = t.x, worldH - spriteSize
            end

            local dx = targetX - t.x
            local dy = targetY - t.y

            -- Stop if close enough to edge (within 2 pixels)
            local distToTarget = math.sqrt(dx * dx + dy * dy)
            if distToTarget < 2 then
                v.dx, v.dy = 0, 0
            else
                v.dx, v.dy = normalize(dx, dy, sad.speed)
            end

        -- Handle Angry Boids
        elseif e.angryBoid then
          
        end
        t.x += v.dx
        t.y += v.dy

        -- Render Boids
          -- Get camera offset
        local camX = 0
        local camY = 0
        if scene.camera then
            camX = scene.camera.x
            camY = scene.camera.y
        end

        if s.visible and s.bubble and s.body then
            local screenX = t.x - camX
            local screenY = t.y - camY
            s.body:moveTo(screenX, screenY)
            s.bubble:moveTo(screenX, screenY-12)
        end
    end
end)
