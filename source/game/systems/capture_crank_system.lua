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

CaptureCrankSystem = System.new("captureCrank", {"transform", "emotionalBattery"}, function(entities, scene)
    -- Only work in capture mode while NOT paused (real-time!)
    if scene.isPaused or scene.currentMode ~= "capture" then
        return
    end

    -- Get crank rotation
    local crankChange = pd.getCrankChange()

    -- DEBUG: B button also advances capture (simulates cranking down) -- RE-ENABLED
    if pd.buttonIsPressed(pd.kButtonB) then
        crankChange = -10  -- Simulate cranking down
    end

    if crankChange < 0 then  -- Cranking DOWN (negative values)
        -- Accumulate capture progress (clamp at 180)
        scene.captureProgress = (scene.captureProgress or 0) + math.abs(crankChange)
        scene.captureProgress = math.min(scene.captureProgress, 180)

        -- Check if threshold reached (180 degrees)
        if scene.captureProgress >= 180 then
            -- Find all boids in capture frame and capture them
            for _, e in ipairs(entities) do
                if not e.captured and isInCameraFrame(e.transform, scene.camera, 80) then
                    -- Check if boid is happy (battery > 60)
                    if e.emotionalBattery.value > 60 then
                        -- Capture this happy boid!
                        e.captured = Captured()
                    else
                        -- Not happy - explode instead!
                        e.exploding = Exploding()

                        -- Track explosion type for stats
                        if e.emotionalBattery.value >= 100 then
                            scene.explosionsHappy = (scene.explosionsHappy or 0) + 1
                        else
                            scene.explosionsAngry = (scene.explosionsAngry or 0) + 1
                        end

                        -- Hide sprites (but don't remove yet - let explosion system handle it)
                        if e.boidsprite and e.boidsprite.body then
                            e.boidsprite.body:setVisible(false)
                        end
                        if e.boidsprite and e.boidsprite.head then
                            e.boidsprite.head:setVisible(false)
                        end
                    end
                end
            end

            -- Reset progress (no unpause needed!)
            scene.captureProgress = 0
        end
    end
end)
