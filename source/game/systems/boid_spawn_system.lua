--[[
    BOID SPAWN SYSTEM
    Spawns new boids periodically when the count is low.

    Spawns 1 boid every 1 second (30 frames) if total boids < 5.

    ── Playdate SDK Quick Reference ──────────────────────

    Time:
        30 frames = 1 second (game runs at 30 FPS)

    ──────────────────────────────────────────────────────
]]

BoidSpawnSystem = System.new("boidSpawn", {}, function(entities, scene)
    -- Initialize spawn timer on first run
    if not scene.spawnTimer then
        scene.spawnTimer = 0
    end

    -- Only spawn when not paused
    if scene.isPaused then
        return
    end

    -- Increment timer
    scene.spawnTimer += 1

    -- Check every 30 frames (1 second)
    if scene.spawnTimer >= 30 then
        scene.spawnTimer = 0

        -- Count current boids (exclude captured boids)
        local boidCount = 0
        for _, entity in ipairs(scene.entities) do
            if entity.emotionalBattery and not entity.captured then
                boidCount += 1
            end
        end

        -- Spawn if below 5
        if boidCount < 5 then
            local worldW = scene.camera.worldWidth
            local worldH = scene.camera.worldHeight
            local padding = scene.camera.padding
            local spriteSize = 32
            local emotions = { "happy", "sad", "angry" }

            -- Get camera viewport bounds
            local camX = scene.camera.x
            local camY = scene.camera.y
            local camRight = camX + SCREEN_WIDTH
            local camBottom = camY + (SCREEN_HEIGHT - 35) -- Account for status bar

            -- Pick random off-screen edge (1=left, 2=right, 3=top, 4=bottom)
            local edge = math.random(1, 4)
            local x, y

            if edge == 1 then
                -- Left edge (off-screen left)
                x = math.random(padding, math.max(padding + 1, camX - spriteSize))
                y = math.random(padding, worldH - padding - spriteSize)
            elseif edge == 2 then
                -- Right edge (off-screen right)
                x = math.random(math.min(worldW - padding - spriteSize, camRight + spriteSize), worldW - padding - spriteSize)
                y = math.random(padding, worldH - padding - spriteSize)
            elseif edge == 3 then
                -- Top edge (off-screen above)
                x = math.random(padding, worldW - padding - spriteSize)
                y = math.random(padding, math.max(padding + 1, camY - spriteSize))
            else
                -- Bottom edge (off-screen below)
                x = math.random(padding, worldW - padding - spriteSize)
                y = math.random(math.min(worldH - padding - spriteSize, camBottom + spriteSize), worldH - padding - spriteSize)
            end

            -- Random emotion
            local emotionType = emotions[math.random(1, 3)]

            -- Set initial battery based on emotion (safe values, not at explosion thresholds)
            local initialBattery = 80
            if emotionType == "happy" then
                initialBattery = 80 -- Safe for happy (61-99, avoiding 100 explosion)
            elseif emotionType == "sad" then
                initialBattery = 50 -- Mid-range for sad (31-60)
            elseif emotionType == "angry" then
                initialBattery = 20 -- Safe for angry (1-30, avoiding 0 explosion)
            end

            -- Create boid with appropriate component
            local boid = Entity.new({
                transform = Transform(x, y),
                velocity = Velocity(0, 0),
                boidsprite = BoidSpriteComp(createEmotionSprite(emotionType), emotionType),
                emotionalBattery = EmotionalBattery(initialBattery)
            })

            -- Add emotion component based on type
            if emotionType == "happy" then
                boid.happyBoid = HappyBoid()
                boid.emotion = "happy"
            elseif emotionType == "sad" then
                boid.sadBoid = SadBoid()
                boid.emotion = "sad"
            elseif emotionType == "angry" then
                boid.angryBoid = AngryBoid()
                boid.emotion = "angry"
            end

            -- Add cleanup method for boid sprites
            function boid:cleanup()
                if self.boidsprite then
                    if self.boidsprite.body then
                        self.boidsprite.body:remove()
                    end
                    if self.boidsprite.head then
                        self.boidsprite.head:remove()
                    end
                end
            end

            scene:addEntity(boid)
        end
    end
end)
