--[[
    EMOTIONAL BATTERY SYSTEM
    Manages the emotional battery that determines boid emotions over time.

    Battery ranges:
        0-30:  Angry
        31-60: Sad
        61+:   Happy

    Drain rates:
        Happy boids: -0.1 per frame (~10 seconds to become sad)
        Sad boids (moving): -0.05 per frame (~20 seconds to become angry)
        Sad boids (stopped at edge): -0.15 per frame (~7 seconds to become angry)
        Angry boids: -0.01 per frame until 0, then stays at 0

    ──────────────────────────────────────────────────────
]]

local gfx = playdate.graphics

-- Helper: Get current emotion type based on battery value
local function getEmotionFromBattery(batteryValue)
    if batteryValue > 60 then
        return "happy"
    elseif batteryValue > 30 then
        return "sad"
    else
        return "angry"
    end
end

-- Helper: Check if boid has stopped moving
local function hasStopped(velocity)
    return velocity.dx == 0 and velocity.dy == 0
end

EmotionalBatterySystem = System.new("emotionalBattery", {"transform", "velocity", "emotionalBattery"}, function(entities, scene)
    for _, e in ipairs(entities) do
        -- Skip captured boids (happiness frozen)
        if e.captured then
            goto continue
        end

        local battery = e.emotionalBattery
        local v = e.velocity

        -- Check for explosion FIRST (before drain) - battery at 0 or 100
        if battery.value <= 0 or battery.value >= 100 then
            -- Track explosion type for stats
            if battery.value >= 100 then
                scene.explosionsHappy = (scene.explosionsHappy or 0) + 1
            else
                scene.explosionsAngry = (scene.explosionsAngry or 0) + 1
            end

            -- Remove sprites from display list immediately
            if e.boidsprite and e.boidsprite.body then
                e.boidsprite.body:remove()
            end
            if e.boidsprite and e.boidsprite.head then
                e.boidsprite.head:remove()
            end

            -- Spawn explosion effect entity at this position
            spawnExplosion(scene, e.transform.x, e.transform.y)

            -- Mark boid for deletion
            e.active = false

            -- Skip rest of processing for this entity
            goto continue
        end

        -- Determine current emotion type (BEFORE camera frame check so it's available later)
        local currentEmotion = nil
        if e.happyBoid then
            currentEmotion = "happy"
        elseif e.sadBoid then
            currentEmotion = "sad"
        elseif e.angryBoid then
            currentEmotion = "angry"
        end

        -- Drain battery based on mode and position
        local shouldDrain = false
        local drainMultiplier = 1.0

        if scene.isPaused then
            -- Influence mode (paused): Only drain boids INSIDE the picture frame at 2x rate!
            -- Frame size is 64px for influence mode (25% larger area than before)
            if isInCameraFrame(e.transform, scene.camera, 64) then
                shouldDrain = true
                drainMultiplier = 2.0  -- Double drain for pressure!
            end
        else
            -- Capture mode (not paused): Only drain boids INSIDE the picture frame at normal rate
            -- Frame size is 40px for capture mode (wide viewport after swap)
            if isInCameraFrame(e.transform, scene.camera, 40) then
                shouldDrain = true
                drainMultiplier = 1.0  -- Normal drain
            end
        end

        if shouldDrain then
            -- Drain battery based on current emotion (30% slower base rate)
            if currentEmotion == "happy" then
                battery.value -= 0.14 * drainMultiplier  -- was 0.2, now with multiplier
            elseif currentEmotion == "sad" then
                if hasStopped(v) then
                    -- At edge, drain faster
                    battery.value -= 0.21 * drainMultiplier  -- was 0.3
                else
                    -- Moving, drain slower
                    battery.value -= 0.07 * drainMultiplier  -- was 0.1
                end
            elseif currentEmotion == "angry" then
                -- Drain to 0 then stop
                if battery.value > 0 then
                    battery.value -= 0.014 * drainMultiplier  -- was 0.02
                end
            end

            -- Clamp battery value
            battery.value = clamp(battery.value, 0, battery.max)
        end

        -- Check if emotion should change
        local newEmotion = getEmotionFromBattery(battery.value)

        if newEmotion ~= currentEmotion then
            -- Remove old emotion component
            e.happyBoid = nil
            e.sadBoid = nil
            e.angryBoid = nil

            -- Add new emotion component
            if newEmotion == "happy" then
                e.happyBoid = HappyBoid()
                -- Reset velocity so BoidSystem picks a random cardinal direction
                v.dx = 0
                v.dy = 0
            elseif newEmotion == "sad" then
                e.sadBoid = SadBoid()
            elseif newEmotion == "angry" then
                e.angryBoid = AngryBoid()
                -- Reset velocity so BoidSystem picks a random diagonal direction
                v.dx = 0
                v.dy = 0
            end

            -- Update sprite
            local newImage = createEmotionSprite(newEmotion)
            if e.sprite then
                e.sprite.image = newImage
            elseif e.boidsprite and e.boidsprite.body and e.boidsprite.head then
                e.boidsprite.emotion = newEmotion
            end
        end

        ::continue::
    end
end)
