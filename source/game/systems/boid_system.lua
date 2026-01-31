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
BoidSystem = System.new("boid", {"transform", "velocity"}, function(entities, scene)
    for _, e in ipairs(entities) do
        local t = e.transform
        local v = e.velocity

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
            v.dx, v.dy = normalize(dx, dy, happy.speed)

        -- Handle Sad Boids
        elseif e.sadBoid then
            local sad = e.sadBoid
            -- Move toward nearest world edge
            local worldW = scene.camera and scene.camera.worldWidth or WORLD_WIDTH
            local worldH = scene.camera and scene.camera.worldHeight or WORLD_HEIGHT

            -- Distance to each edge
            local distLeft = t.x
            local distRight = worldW - t.x
            local distTop = t.y
            local distBottom = worldH - t.y

            -- Find closest edge
            local minDist = math.min(distLeft, distRight, distTop, distBottom)
            local targetX, targetY

            if minDist == distLeft then
                targetX, targetY = 0, t.y
            elseif minDist == distRight then
                targetX, targetY = worldW, t.y
            elseif minDist == distTop then
                targetX, targetY = t.x, 0
            else
                targetX, targetY = t.x, worldH
            end

            local dx = targetX - t.x
            local dy = targetY - t.y
            v.dx, v.dy = normalize(dx, dy, sad.speed)

        -- Handle Angry Boids
        elseif e.angryBoid then
            local angry = e.angryBoid
            -- Move toward closest non-angry boid
            local closestDist = math.huge
            local closestBoid = nil

            -- Check all entities for non-angry boids (happy or sad)
            for _, other in ipairs(scene.entities) do
                if other.active and other.id ~= e.id then
                    if other.happyBoid or other.sadBoid then
                        local dist = distance(t.x, t.y, other.transform.x, other.transform.y)
                        if dist < closestDist and dist <= angry.detectionRange then
                            closestDist = dist
                            closestBoid = other
                        end
                    end
                end
            end

            if closestBoid then
                local dx = closestBoid.transform.x - t.x
                local dy = closestBoid.transform.y - t.y
                v.dx, v.dy = normalize(dx, dy, angry.speed)
            else
                -- No target, stay still
                v.dx, v.dy = 0, 0
            end
        end
    end
end)
