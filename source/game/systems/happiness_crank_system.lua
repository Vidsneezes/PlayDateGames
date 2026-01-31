--[[
    HAPPINESS CRANK SYSTEM
    Allows player to increase happiness of visible boids by cranking.

    Only boids currently visible on screen are affected.
    Crank rotation increases their emotional battery.

    ── Playdate SDK Quick Reference ──────────────────────

    Crank input:
        playdate.getCrankChange()           -- degrees rotated since last frame
        playdate.isCrankDocked()            -- true if crank is folded in
        playdate.getCrankPosition()         -- absolute angle 0-360

    Example:
        local change = playdate.getCrankChange()
        if change ~= 0 then
            -- Crank was rotated 'change' degrees
        end

    ──────────────────────────────────────────────────────
]]

local pd = playdate

-- Helper: Check if a boid is visible in the current viewport
local function isVisible(transform, camera)
    local camX = camera.x
    local camY = camera.y

    -- Check if boid is within viewport bounds
    return transform.x >= camX and transform.x <= camX + SCREEN_WIDTH and
           transform.y >= camY and transform.y <= camY + SCREEN_HEIGHT
end

HappinessCrankSystem = System.new("happinessCrank", {"transform", "emotionalBattery"}, function(entities, scene)
    -- Crank only works while paused
    if not scene.isPaused then
        return
    end

    -- Get crank rotation
    local crankChange = pd.getCrankChange()

    if crankChange ~= 0 and scene.camera then
        -- Find all visible boids
        local visibleBoids = {}
        for _, e in ipairs(entities) do
            if isVisible(e.transform, scene.camera) then
                visibleBoids[#visibleBoids + 1] = e
            end
        end

        -- Apply happiness increase to visible boids
        -- TESTING: Very high crank power - 360 degrees = +200 happiness total
        -- TODO: Adjust this value for proper game balance
        -- Distributed among all visible boids
        if #visibleBoids > 0 then
            local happinessPerDegree = 200 / 360  -- ~0.56 per degree (very high for testing)
            local totalIncrease = crankChange * happinessPerDegree
            local increasePerBoid = totalIncrease / #visibleBoids

            for _, boid in ipairs(visibleBoids) do
                boid.emotionalBattery.value += increasePerBoid
                boid.emotionalBattery.value = clamp(boid.emotionalBattery.value, 0, 100)
            end
        end
    end
end)
