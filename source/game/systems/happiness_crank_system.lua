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

HappinessCrankSystem = System.new("happinessCrank", {"transform", "emotionalBattery"}, function(entities, scene)
    -- Only work while paused in influence mode
    if not scene.isPaused or scene.currentMode ~= "influence" then
        return
    end

    -- Get crank rotation
    local crankChange = pd.getCrankChange()

    if crankChange ~= 0 and scene.camera then
        -- Find all boids within camera frame (80px inset - NARROW for testing)
        local frameBoids = {}
        for _, e in ipairs(entities) do
            if isInCameraFrame(e.transform, scene.camera, 80) then
                frameBoids[#frameBoids + 1] = e
            end
        end

        -- Apply happiness increase to boids in frame
        -- Crank power: 360 degrees = +180 happiness total (10% less for balance)
        -- Distributed among all boids in camera frame
        if #frameBoids > 0 then
            local happinessPerDegree = 180 / 360  -- was 200/360, now 10% less
            local totalIncrease = crankChange * happinessPerDegree
            local increasePerBoid = totalIncrease / #frameBoids

            for _, boid in ipairs(frameBoids) do
                boid.emotionalBattery.value += increasePerBoid
                boid.emotionalBattery.value = clamp(boid.emotionalBattery.value, 0, 100)
            end
        end
    end
end)
