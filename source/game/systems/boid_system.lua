--[[
    BOID SYSTEM
    Controls boid movement based on emotional state.

    Happy boids → move toward world center
    Sad boids   → move toward nearest world edge
    Angry boids → move toward closest non-angry boid

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

BoidSystem = System.new("boid", {"transform", "velocity", "emotion"}, function(entities, scene)
    for _, e in ipairs(entities) do
        local t = e.transform
        local v = e.velocity
        local emotion = e.emotion

        if emotion.type == "happy" then
            -- Move toward world center
            local worldW = scene.camera and scene.camera.worldWidth or WORLD_WIDTH
            local worldH = scene.camera and scene.camera.worldHeight or WORLD_HEIGHT
            local targetX = worldW / 2
            local targetY = worldH / 2
            local dx = targetX - t.x
            local dy = targetY - t.y
            v.dx, v.dy = normalize(dx, dy, 1.5)

        elseif emotion.type == "sad" then
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
            v.dx, v.dy = normalize(dx, dy, 1.0)

        elseif emotion.type == "angry" then
            -- Move toward closest non-angry boid
            local allBoids = scene:getEntitiesWith("emotion")
            local closestDist = math.huge
            local closestBoid = nil

            for _, other in ipairs(allBoids) do
                if other.id ~= e.id and other.emotion.type ~= "angry" then
                    local dist = distance(t.x, t.y, other.transform.x, other.transform.y)
                    if dist < closestDist then
                        closestDist = dist
                        closestBoid = other
                    end
                end
            end

            if closestBoid then
                local dx = closestBoid.transform.x - t.x
                local dy = closestBoid.transform.y - t.y
                v.dx, v.dy = normalize(dx, dy, 2.0)
            else
                -- No target, stay still
                v.dx, v.dy = 0, 0
            end
        end
    end
end)
