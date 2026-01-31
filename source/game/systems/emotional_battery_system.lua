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

-- Helper: Create sprite for emotion type
-- PLACEHOLDER SHAPES RE-ENABLED at 32x32 for testing
local function createEmotionSprite(emotionType)
    local img = gfx.image.new(32, 32, gfx.kColorWhite)
    gfx.lockFocus(img)
    gfx.setColor(gfx.kColorBlack)

    if emotionType == "happy" then
        -- Triangle (pointing up) - scaled to 32x32
        gfx.fillPolygon(16, 4, 28, 28, 4, 28)
    elseif emotionType == "sad" then
        -- Circle - scaled to 32x32
        gfx.fillCircleAtPoint(16, 16, 14)
    elseif emotionType == "angry" then
        -- Square - scaled to 32x32
        gfx.fillRect(4, 4, 24, 24)
    end

    gfx.unlockFocus()
    return img
end

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
        local battery = e.emotionalBattery
        local v = e.velocity

        -- Determine current emotion type
        local currentEmotion = nil
        if e.happyBoid then
            currentEmotion = "happy"
        elseif e.sadBoid then
            currentEmotion = "sad"
        elseif e.angryBoid then
            currentEmotion = "angry"
        end

        -- Drain battery based on current emotion (increased rates for more challenge)
        if currentEmotion == "happy" then
            battery.value -= 0.2  -- was 0.1 (~5 sec to sad)
        elseif currentEmotion == "sad" then
            if hasStopped(v) then
                -- At edge, drain faster
                battery.value -= 0.3  -- was 0.15 (~3.5 sec to angry)
            else
                -- Moving, drain slower
                battery.value -= 0.1  -- was 0.05 (~10 sec to angry)
            end
        elseif currentEmotion == "angry" then
            -- Drain to 0 then stop
            if battery.value > 0 then
                battery.value -= 0.02  -- was 0.01
            end
        end

        -- Clamp battery value
        battery.value = clamp(battery.value, 0, battery.max)

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
            elseif e.boidsprite and e.boidsprite.body then
                e.boidsprite.body:setImage(newImage)
            end
        end
    end
end)
