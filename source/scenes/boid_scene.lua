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
        self:addSystem(BoidSpawnSystem)        -- Spawn new boids when count is low
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
        self:addSystem(RenderUISystem)         -- Draw UI elements (status bar, bombs, frame, etc.)
        self:addSystem(ScreenFlashSystem)      -- Screen flash effect (SAD bomb) - MUST BE LAST

        -- Spawn test boids
        -- ADJUST THIS NUMBER to test performance
        local BOID_COUNT = 5 -- Start small, BoidSpawnSystem will add more
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
                GAME_WORLD:queueScene(WinScene(self.explosionsHappy, self.explosionsAngry))
                return
            end

            -- Lose if 5 boids exploded
            if (self.explosionsHappy + self.explosionsAngry) >= 5 then
                GAME_WORLD:queueScene(LoseScene(self.explosionsHappy, self.explosionsAngry))
                return
            end
        end

        -- UI is now handled by RenderUISystem
    end

    return scene
end
