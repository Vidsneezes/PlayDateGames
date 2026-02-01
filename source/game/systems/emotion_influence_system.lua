--[[
    EMOTION INFLUENCE SYSTEM
    Proximity-based emotional effects:
    - Angry boids drain happiness of nearby boids faster
    - Sad boids drain faster when near world edges

    This system can be commented out if it's too resource intensive.

    ── Playdate SDK Quick Reference ──────────────────────

    Math:
        math.sqrt(x)
        math.abs(x)

    ──────────────────────────────────────────────────────
]]

EmotionInfluenceSystem = System.new("emotionInfluence", {"transform", "emotionalBattery"}, function(entities, scene)
    -- No proximity effects while paused
    if scene.isPaused then
        return
    end

    -- Configuration
    local ANGRY_INFLUENCE_RADIUS = 80      -- pixels (was 60)
    local ANGRY_DRAIN_AMOUNT = 0.25        -- extra drain per frame (was 0.15)
    local EDGE_DANGER_ZONE = 40            -- pixels from edge
    local EDGE_DRAIN_AMOUNT = 0.2          -- extra drain per frame

    local worldW = scene.camera and scene.camera.worldWidth or 800
    local worldH = scene.camera and scene.camera.worldHeight or 480
    local spriteSize = 32

    -- First pass: Angry boids drain nearby boids
    for _, angry in ipairs(entities) do
        if angry.angryBoid then
            local ax = angry.transform.x
            local ay = angry.transform.y

            -- Check all other boids
            for _, victim in ipairs(entities) do
                if victim ~= angry then
                    local vx = victim.transform.x
                    local vy = victim.transform.y

                    -- Calculate distance (using squared distance to avoid sqrt)
                    local dx = vx - ax
                    local dy = vy - ay
                    local distSquared = dx * dx + dy * dy
                    local radiusSquared = ANGRY_INFLUENCE_RADIUS * ANGRY_INFLUENCE_RADIUS

                    -- If within influence radius, drain happiness
                    if distSquared < radiusSquared then
                        victim.emotionalBattery.value -= ANGRY_DRAIN_AMOUNT
                        victim.emotionalBattery.value = math.max(0, victim.emotionalBattery.value)
                    end
                end
            end
        end
    end

    -- Second pass: Sad boids near edges drain faster
    for _, sad in ipairs(entities) do
        if sad.sadBoid then
            local x = sad.transform.x
            local y = sad.transform.y

            -- Check distance to all 4 edges
            local distToLeft = x
            local distToRight = worldW - spriteSize - x
            local distToTop = y
            local distToBottom = worldH - spriteSize - y

            -- Find closest edge
            local closestEdge = math.min(distToLeft, distToRight, distToTop, distToBottom)

            -- If in danger zone, extra drain
            if closestEdge < EDGE_DANGER_ZONE then
                sad.emotionalBattery.value -= EDGE_DRAIN_AMOUNT
                sad.emotionalBattery.value = math.max(0, sad.emotionalBattery.value)
            end
        end
    end
end)
