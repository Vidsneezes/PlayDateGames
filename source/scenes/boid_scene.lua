--[[
    BOID SCENE
    Test scene for boid emotion AI system.

    Controls:
        Arrow keys - Move camera

    Boids:
        Triangle - Happy (moves to world center)
        Circle   - Sad (moves to world edge)
        Square   - Angry (chases other boids)
]]

local gfx = playdate.graphics

function BoidScene()
    local scene = Scene.new("boid")

    -- Camera for scrolling world (4x viewport area + 100px padding on each side)
    local worldW = SCREEN_WIDTH * 2 + 200   -- 1000
    local worldH = SCREEN_HEIGHT * 2 + 200  -- 680

    scene.camera = {
        x = (worldW - SCREEN_WIDTH) / 2,   -- Center horizontally: (1000 - 400) / 2 = 300
        y = (worldH - SCREEN_HEIGHT) / 2,  -- Center vertically: (680 - 240) / 2 = 220
        worldWidth = worldW,
        worldHeight = worldH,
        padding = 100                      -- Boids cannot enter this padded border area
    }

    -- Pause state (starts in capture mode = not paused)
    scene.isPaused = false

    -- Current mode (starts in capture mode so game is running!)
    scene.currentMode = "capture" -- "influence" or "capture"
    scene.captureProgress = 0     -- progress toward capturing (0-180 degrees)

    -- Mask animation state
    scene.maskAnimation = {
        state = "idle",           -- "idle" | "putting_on" | "taking_off"
        frame = 0,                -- current animation frame (0-indexed)
        frameTimer = 0,           -- frames until next animation frame
        framesPerStep = 2,        -- how many game frames per animation frame (2 = 15fps animation at 30fps game)
        targetMode = nil          -- mode to switch to after animation completes
    }

    -- Track explosions
    scene.explosionsHappy = 0 -- exploded at 100 happiness
    scene.explosionsAngry = 0 -- exploded at 0 happiness

    -- SAD Bomb (emergency tool)
    scene.sadBombs = 3        -- remaining charges
    scene.screenFlash = 0     -- frames of white flash remaining (0 = no flash)

    -- Helper: Spawn multiple boids with random positions and emotions
    local function spawnRandomBoids(scene, count)
        local worldW = scene.camera.worldWidth
        local worldH = scene.camera.worldHeight
        local padding = scene.camera.padding
        local spriteSize = 32 -- Updated to 32x32 for testing
        local emotions = { "happy", "sad", "angry" }

        for i = 1, count do
            -- Random position (keeping sprite in bounds, respecting padding)
            local x = math.random(padding, worldW - padding - spriteSize)
            local y = math.random(padding, worldH - padding - spriteSize)

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

    function scene:onEnter()
        -- Register systems in execution order
        self:addSystem(CameraSystem)
        self:addSystem(BombSystem)             -- B button: SAD bomb
        self:addSystem(HappinessCrankSystem)   -- Influence mode: crank UP for happiness
        self:addSystem(CaptureCrankSystem)     -- Capture mode: crank DOWN to capture
        self:addSystem(EmotionalBatterySystem) -- Update emotions after happiness changes
        self:addSystem(EmotionInfluenceSystem) -- Proximity effects (comment out if too slow)
        self:addSystem(BoidSystem)             -- Update boid AI and sprites
        self:addSystem(ExplosionEffectSystem)  -- Update explosion entity lifetimes
        self:addSystem(AudioMusicSystem)       -- Dynamic music based on boid counts
        self:addSystem(RenderClearSystem)      -- Clear screen to white
        self:addSystem(RenderBackgroundSystem) -- Draw grass tilemap
        self:addSystem(RenderSpriteSystem)     -- Draw boid sprites
        self:addSystem(RenderBoidHPSystem)     -- Draw HP bars on top of sprites
        self:addSystem(RenderCapturedSystem)   -- Draw squares around captured boids
        self:addSystem(RenderExplosionSystem)  -- Draw explosions and cleanup
        self:addSystem(RenderExplosionMarkSystem) -- Draw RIP marks (must be after sprites)
        self:addSystem(RenderMaskSystem)       -- Draw mode-specific mask overlay (RE-ENABLED FOR TESTING)
        self:addSystem(ScreenFlashSystem)      -- Screen flash effect (SAD bomb) - MUST BE LAST
        -- self:addSystem(RenderUISystem)           -- Happiness gauge (DISABLED - using individual HP bars)

        -- Spawn test boids
        -- ADJUST THIS NUMBER to test performance
        local BOID_COUNT = 10 -- Small count for testing gameplay feel
        spawnRandomBoids(self, BOID_COUNT)

        -- Store total count for win screen
        self.totalBoidCount = BOID_COUNT
    end

    function scene:onExit()
        -- Stop game music
        SoundBank.stopMusic()

        -- Clean up all entities (each entity handles its own resources)
        for _, entity in ipairs(self.entities) do
            -- Call cleanup method if entity has one
            if entity.cleanup then
                entity:cleanup()
            end
            -- Mark inactive
            entity.active = false
        end

        -- Clean up tilemap (force recreation on next scene)
        self.backgroundTilemap = nil
        bgset = false

        print("BoidScene cleanup complete - " .. #self.entities .. " entities cleaned")
    end

    function scene:update()
        -- A button switches mode (instant transition)
        if playdate.buttonJustPressed(playdate.kButtonA) then
            self.currentMode = (self.currentMode == "influence") and "capture" or "influence"
            self.captureProgress = 0 -- reset capture progress when switching

            -- Update pause state based on mode
            if self.currentMode == "influence" then
                self.isPaused = true  -- Pause for influence
            else
                self.isPaused = false -- Unpause for capture
            end
        end

        -- B button does nothing (removed old logic)
        Scene.update(self) -- runs all registered systems


        -- Check win/lose conditions (only when not paused)
        if not self.isPaused then
            local allHappy = true
            local allAngry = true
            local boidCount = 0
            local capturedCount = 0

            for _, entity in ipairs(self.entities) do
                if entity.emotionalBattery then
                    if entity.captured then
                        capturedCount += 1
                    else
                        -- Only count non-captured boids for happiness check
                        boidCount += 1

                        -- Check happiness (battery > 60)
                        if entity.emotionalBattery.value <= 60 then
                            allHappy = false
                        end

                        -- Check if angry (has angryBoid component)
                        if not entity.angryBoid then
                            allAngry = false
                        end
                    end
                end
            end

            -- Win if you capture 5 boids
            if capturedCount >= 5 then
                -- Pass actual survivor count (non-captured + captured)
                local survivorCount = boidCount + capturedCount
                GAME_WORLD:queueScene(WinScene(survivorCount, self.explosionsHappy, self.explosionsAngry))
                return
            end

            -- Lose if 5 boids exploded
            if (self.explosionsHappy + self.explosionsAngry) >= 5 then
                GAME_WORLD:queueScene(LoseScene())
                return
            end
        end

        -- Count emotions in a single loop
        local happyCount = 0
        local sadCount = 0
        local angryCount = 0

        for _, entity in ipairs(self.entities) do
            if entity.happyBoid then
                happyCount += 1
            elseif entity.sadBoid then
                sadCount += 1
            elseif entity.angryBoid then
                angryCount += 1
            end
        end

        -- UI Layout constants
        local statusBarHeight = 35
        local gaugeWidth = 30 -- includes padding
        local frameSize = 10

        -- Draw bottom status bar (white background)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, SCREEN_HEIGHT - statusBarHeight, SCREEN_WIDTH, statusBarHeight)

        -- Draw status bar border
        gfx.setColor(gfx.kColorBlack)
        gfx.drawLine(0, SCREEN_HEIGHT - statusBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - statusBarHeight)

        -- Draw status bar text (emotion counts and bomb count)
        local statusY = SCREEN_HEIGHT - statusBarHeight + 10
        gfx.drawText("Happy: " .. happyCount .. "  Sad: " .. sadCount .. "  Angry: " .. angryCount .. "  Bombs: " .. self.sadBombs, 10, statusY)

        -- Draw mode indicator in lower right (UI area)
        local modeText
        if self.currentMode == "influence" then
            modeText = "Mode: Influence"
        else -- capture mode
            modeText = "Mode: Capture"
        end

        local textWidth = gfx.getTextSize(modeText)
        local boxPadding = 5 -- larger box
        local modeX = SCREEN_WIDTH - textWidth - 15
        local modeY = SCREEN_HEIGHT - statusBarHeight + 10

        -- Simple box with black text (same style for both states)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(modeX - boxPadding, modeY - 3, textWidth + boxPadding * 2, 20)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(modeX - boxPadding, modeY - 3, textWidth + boxPadding * 2, 20)
        gfx.drawText(modeText, modeX, modeY)

        -- Draw camera frame (size depends on mode) -- SWAPPED FOR TESTING
        -- Influence mode: smaller frame (64px inset - 25% larger than before) -- SWAPPED!
        -- Capture mode: larger frame (40px inset) -- SWAPPED!
        local frameInset = (self.currentMode == "capture") and 40 or 64
        local frameWidth = SCREEN_WIDTH - (frameInset * 2)
        local frameHeight = (SCREEN_HEIGHT - statusBarHeight) - (frameInset * 2)

        local playLeft = frameInset
        local playTop = frameInset
        local playRight = frameInset + frameWidth
        local playBottom = frameInset + frameHeight

        -- Top-left corner
        gfx.drawLine(playLeft, playTop, playLeft + frameSize, playTop)
        gfx.drawLine(playLeft, playTop, playLeft, playTop + frameSize)

        -- Top-right corner
        gfx.drawLine(playRight - frameSize, playTop, playRight, playTop)
        gfx.drawLine(playRight, playTop, playRight, playTop + frameSize)

        -- Bottom-left corner
        gfx.drawLine(playLeft, playBottom, playLeft + frameSize, playBottom)
        gfx.drawLine(playLeft, playBottom - frameSize, playLeft, playBottom)

        -- Bottom-right corner
        gfx.drawLine(playRight - frameSize, playBottom, playRight, playBottom)
        gfx.drawLine(playRight, playBottom - frameSize, playRight, playBottom)

        -- Center cross (in middle of playable area)
        local centerX = (playLeft + playRight) / 2
        local centerY = (playTop + playBottom) / 2
        local crossSize = 5
        gfx.drawLine(centerX - crossSize, centerY, centerX + crossSize, centerY)
        gfx.drawLine(centerX, centerY - crossSize, centerX, centerY + crossSize)

        -- Show capture progress bar below center cross (only when there's meaningful progress)
        if self.currentMode == "capture" and self.captureProgress >= 10 then
            local progBarWidth = 80
            local progBarHeight = 6
            local progBarX = centerX - progBarWidth / 2
            local progBarY = centerY + 15 -- below the cross

            -- Background
            gfx.setColor(gfx.kColorWhite)
            gfx.fillRect(progBarX, progBarY, progBarWidth, progBarHeight)

            -- Border
            gfx.setColor(gfx.kColorBlack)
            gfx.drawRect(progBarX, progBarY, progBarWidth, progBarHeight)

            -- Fill based on progress (0-180 degrees)
            local fillWidth = (self.captureProgress / 180) * progBarWidth
            if fillWidth > 0 then
                gfx.setColor(gfx.kColorBlack)
                gfx.fillRect(progBarX + 1, progBarY + 1, fillWidth - 2, progBarHeight - 2)
            end
        end
    end

    return scene
end
