--[[
    AUDIO MUSIC SYSTEM
    Tracks boid counts and plays different music based on game state.

    This system counts:
    - Total boids remaining (not exploded)
    - Captured boids (frozen)
    - Free boids (moving)
    - Emotion counts (happy, sad, angry)

    Use this data to trigger different music tracks or intensity levels.

    ── For Audio Implementation ──────────────────────────

    Available data each frame:
    - totalBoids: All boids still alive (captured + free)
    - capturedBoids: Boids that are frozen
    - freeBoids: Boids still moving
    - happyBoids: Boids with happy emotion
    - sadBoids: Boids with sad emotion
    - angryBoids: Boids with angry emotion

    Example music triggers:
    - High tension when many angry boids
    - Calm music when most are captured
    - Victory music when almost all happy
    - Danger music when few boids left

    ──────────────────────────────────────────────────────
]]

AudioMusicSystem = System.new("audioMusic", {"emotionalBattery"}, function(entities, scene)
    -- Count boids by state
    local totalBoids = 0
    local capturedBoids = 0
    local freeBoids = 0
    local happyBoids = 0
    local sadBoids = 0
    local angryBoids = 0

    for _, e in ipairs(entities) do
        if e.emotionalBattery then
            totalBoids += 1

            -- Count captured vs free
            if e.captured then
                capturedBoids += 1
            else
                freeBoids += 1
            end

            -- Count emotions
            if e.happyBoid then
                happyBoids += 1
            elseif e.sadBoid then
                sadBoids += 1
            elseif e.angryBoid then
                angryBoids += 1
            end
        end
    end

    -- Calculate percentages for easier thresholds
    local capturePercent = totalBoids > 0 and (capturedBoids / totalBoids) * 100 or 0
    local happyPercent = totalBoids > 0 and (happyBoids / totalBoids) * 100 or 0
    local angryPercent = totalBoids > 0 and (angryBoids / totalBoids) * 100 or 0

    --[[
        ════════════════════════════════════════════════════
        AUDIO IMPLEMENTATION AREA
        ════════════════════════════════════════════════════

        Add your music logic here!

        Example ideas:

        -- Play tense music when many angry boids
        if angryPercent > 50 then
            -- playMusic("tense_theme")
        end

        -- Play calm music when most captured
        if capturePercent > 75 then
            -- playMusic("calm_theme")
        end

        -- Play victory music when almost all happy
        if happyPercent > 80 then
            -- playMusic("victory_theme")
        end

        -- Play danger music when few boids left
        if totalBoids <= 3 and freeBoids > 0 then
            -- playMusic("danger_theme")
        end

        -- Adaptive music intensity based on free angry boids
        local freeAngryBoids = angryBoids - capturedBoids
        if freeAngryBoids > 5 then
            -- setMusicIntensity("high")
        end

        ════════════════════════════════════════════════════
    ]]

    -- YOUR AUDIO CODE HERE!
    -- You have access to all the count variables above


end)
