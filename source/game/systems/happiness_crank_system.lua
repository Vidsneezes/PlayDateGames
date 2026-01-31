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

-- Helper: Check if a boid is within the camera frame (not just viewport)
local function isInCameraFrame(transform, camera)
    local camX = camera.x
    local camY = camera.y

    -- Convert world coordinates to screen coordinates
    local screenX = transform.x - camX
    local screenY = transform.y - camY

    -- Camera frame bounds (matching boid_scene.lua frame)
    local frameInset = 40
    local statusBarHeight = 35
    local gaugeWidth = 30

    local frameLeft = frameInset
    local frameTop = frameInset
    local frameRight = frameInset + (SCREEN_WIDTH - (frameInset * 2))
    local frameBottom = frameInset + ((SCREEN_HEIGHT - statusBarHeight) - (frameInset * 2))

    -- Check if boid is within frame bounds
    return screenX >= frameLeft and screenX <= frameRight and
           screenY >= frameTop and screenY <= frameBottom
end

HappinessCrankSystem = System.new("happinessCrank", {"transform", "emotionalBattery"}, function(entities, scene)
    -- Crank only works while paused in influence mode
    if not scene.isPaused or scene.currentMode ~= "influence" then
        return
    end

    -- Get crank rotation
    local crankChange = pd.getCrankChange()

    if crankChange ~= 0 and scene.camera then
        -- Find all boids within camera frame
        local frameBoids = {}
        for _, e in ipairs(entities) do
            if isInCameraFrame(e.transform, scene.camera) then
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
