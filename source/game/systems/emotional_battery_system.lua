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
-- PLACEHOLDER SHAPES DISABLED - using real sprites now
local function createEmotionSprite(emotionType)
    local img = gfx.image.new(16, 16, gfx.kColorWhite)
    -- gfx.lockFocus(img)
    -- gfx.setColor(gfx.kColorBlack)

    -- if emotionType == "happy" then
    --     gfx.fillPolygon(8, 2, 14, 14, 2, 14)  -- Triangle
    -- elseif emotionType == "sad" then
    --     gfx.fillCircleAtPoint(8, 8, 7)  -- Circle
    -- elseif emotionType == "angry" then
    --     gfx.fillRect(2, 2, 12, 12)  -- Square
    -- end

    -- gfx.unlockFocus()
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

        -- Drain battery based on current emotion
        if currentEmotion == "happy" then
            battery.value -= 0.1
        elseif currentEmotion == "sad" then
            if hasStopped(v) then
                -- At edge, drain faster
                battery.value -= 0.15
            else
                -- Moving, drain slower
                battery.value -= 0.05
            end
        elseif currentEmotion == "angry" then
            -- Drain to 0 then stop
            if battery.value > 0 then
                battery.value -= 0.01
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
