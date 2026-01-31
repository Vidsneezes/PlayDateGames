--[[
    CAPTURE CRANK SYSTEM
    Allows player to capture boids by cranking DOWN while paused in capture mode.

    Captured boids are frozen in place with locked happiness.

    ── Playdate SDK Quick Reference ──────────────────────

    Crank input:
        playdate.getCrankChange()  -- degrees rotated since last frame

    ──────────────────────────────────────────────────────
]]

local pd = playdate

-- Helper: Check if a boid is within the SMALLER capture frame
local function isInCaptureFrame(transform, camera)
    local camX = camera.x
    local camY = camera.y

    -- Convert to screen coordinates
    local screenX = transform.x - camX
    local screenY = transform.y - camY

    -- Capture frame is HALF the size (80px inset instead of 40px)
    local frameInset = 80
    local statusBarHeight = 35
    local frameLeft = frameInset
    local frameTop = frameInset
    local frameRight = frameInset + (SCREEN_WIDTH - (frameInset * 2))
    local frameBottom = frameInset + ((SCREEN_HEIGHT - statusBarHeight) - (frameInset * 2))

    return screenX >= frameLeft and screenX <= frameRight and
           screenY >= frameTop and screenY <= frameBottom
end

CaptureCrankSystem = System.new("captureCrank", {"transform", "emotionalBattery"}, function(entities, scene)
    -- Only work while paused in capture mode
    if not scene.isPaused or scene.currentMode ~= "capture" then
        return
    end

    -- Get crank rotation
    local crankChange = pd.getCrankChange()

    if crankChange < 0 then  -- Cranking DOWN (negative values)
        -- Accumulate capture progress
        scene.captureProgress = (scene.captureProgress or 0) + math.abs(crankChange)

        -- Check if threshold reached (180 degrees)
        if scene.captureProgress >= 180 then
            -- Find all boids in capture frame and capture them
            for _, e in ipairs(entities) do
                if not e.captured and isInCaptureFrame(e.transform, scene.camera) then
                    -- Capture this boid!
                    e.captured = Captured()
                end
            end

            -- Reset progress
            scene.captureProgress = 0
        end
    end
end)
