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
    scene.camera = {
        x = 0,
        y = 0,
        worldWidth = SCREEN_WIDTH * 2 + 200,   -- 1000 (800 + 100px padding on each side)
        worldHeight = SCREEN_HEIGHT * 2 + 200, -- 680 (480 + 100px padding on each side)
        padding = 100  -- Boids cannot enter this padded border area
    }

    -- Pause state (starts playing)
    scene.isPaused = false

    -- Current mode (influence = happiness, capture = freeze boids)
    scene.currentMode = "influence"  -- "influence" or "capture"
    scene.captureProgress = 0        -- progress toward capturing (0-180 degrees)

    -- Track explosions
    scene.explosionsHappy = 0  -- exploded at 100 happiness
    scene.explosionsAngry = 0  -- exploded at 0 happiness

    -- Helper: Create temporary sprite for each emotion type
    -- PLACEHOLDER SHAPES RE-ENABLED at 32x32 for testing
    local function createBoidSprite(emotionType)
        local img = boidSpriteHappy

        if emotionType == "happy" then
            -- Triangle (pointing up)
            img = boidSpriteHappy
        elseif emotionType == "sad" then
            -- Circle
            img = boidSpriteSad
        elseif emotionType == "angry" then
            -- Square
            img = boidSpriteAngry
        end

        return img
    end

    -- Helper: Spawn multiple boids with random positions and emotions
    local function spawnRandomBoids(scene, count)
        local worldW = scene.camera.worldWidth
        local worldH = scene.camera.worldHeight
        local padding = scene.camera.padding
        local spriteSize = 32  -- Updated to 32x32 for testing
        local emotions = {"happy", "sad", "angry"}

        for i = 1, count do
            -- Random position (keeping sprite in bounds, respecting padding)
            local x = math.random(padding, worldW - padding - spriteSize)
            local y = math.random(padding, worldH - padding - spriteSize)

            -- Random emotion
            local emotionType = emotions[math.random(1, 3)]

            -- Set initial battery based on emotion (safe values, not at explosion thresholds)
            local initialBattery = 80
            if emotionType == "happy" then
                initialBattery = 80   -- Safe for happy (61-99, avoiding 100 explosion)
            elseif emotionType == "sad" then
                initialBattery = 50   -- Mid-range for sad (31-60)
            elseif emotionType == "angry" then
                initialBattery = 20   -- Safe for angry (1-30, avoiding 0 explosion)
            end

            -- Create boid with appropriate component
            local boid = Entity.new({
                transform = Transform(x, y),
                velocity = Velocity(0, 0),
                boidsprite = BoidSpriteComp(createBoidSprite(emotionType)),
                emotionalBattery = EmotionalBattery(initialBattery)
            })

            -- Add emotion component based on type
            if emotionType == "happy" then
                boid.happyBoid = HappyBoid()
            elseif emotionType == "sad" then
                boid.sadBoid = SadBoid()
            elseif emotionType == "angry" then
                boid.angryBoid = AngryBoid()
            end

            scene:addEntity(boid)
        end
    end

    function scene:onEnter()
        -- Register systems in execution order
        self:addSystem(CameraSystem)
        self:addSystem(HappinessCrankSystem)     -- Influence mode: crank UP for happiness
        self:addSystem(CaptureCrankSystem)       -- Capture mode: crank DOWN to capture
        self:addSystem(EmotionalBatterySystem)   -- Update emotions after happiness changes
        self:addSystem(EmotionInfluenceSystem)   -- Proximity effects (comment out if too slow)
        self:addSystem(BoidSystem)               -- Update boid AI and sprites
        self:addSystem(RenderClearSystem)        -- Clear screen to white
        self:addSystem(RenderBackgroundSystem)   -- Draw grass tilemap
        self:addSystem(RenderSpriteSystem)       -- Draw boid sprites
        self:addSystem(RenderBoidHPSystem)       -- Draw HP bars on top of sprites
        self:addSystem(RenderCapturedSystem)     -- Draw squares around captured boids
        self:addSystem(RenderExplosionSystem)    -- Draw explosions and cleanup
        -- self:addSystem(RenderUISystem)           -- Happiness gauge (DISABLED - using individual HP bars)

        -- Spawn test boids
        -- ADJUST THIS NUMBER to test performance
        local BOID_COUNT = 10  -- Small count for testing gameplay feel
        spawnRandomBoids(self, BOID_COUNT)

        -- Store total count for win screen
        self.totalBoidCount = BOID_COUNT
    end

    function scene:onExit()
        -- Clean up if needed
    end

    function scene:update()
        -- A button toggles pause
        if playdate.buttonJustPressed(playdate.kButtonA) then
            self.isPaused = not self.isPaused
        end

        -- B button switches mode (while playing)
        if playdate.buttonJustPressed(playdate.kButtonB) and not self.isPaused then
            self.currentMode = (self.currentMode == "influence") and "capture" or "influence"
            self.captureProgress = 0  -- reset capture progress when switching
        end

        -- B button increases happiness (crank alternative) - only while paused in influence mode
        if playdate.buttonJustPressed(playdate.kButtonB) and self.isPaused and self.currentMode == "influence" then
            -- Helper: Check if a boid is within the camera frame
            local function isInCameraFrame(transform)
                local camX = self.camera.x
                local camY = self.camera.y
                local screenX = transform.x - camX
                local screenY = transform.y - camY

                local frameInset = 40
                local statusBarHeight = 35
                local frameLeft = frameInset
                local frameTop = frameInset
                local frameRight = frameInset + (SCREEN_WIDTH - (frameInset * 2))
                local frameBottom = frameInset + ((SCREEN_HEIGHT - statusBarHeight) - (frameInset * 2))

                return screenX >= frameLeft and screenX <= frameRight and
                       screenY >= frameTop and screenY <= frameBottom
            end

            -- Find boids in frame and increase happiness
            local happinessIncrease = 10  -- Fixed amount per B press
            for _, entity in ipairs(self.entities) do
                if entity.emotionalBattery and entity.transform then
                    if isInCameraFrame(entity.transform) then
                        entity.emotionalBattery.value += happinessIncrease
                        entity.emotionalBattery.value = clamp(entity.emotionalBattery.value, 0, 100)
                    end
                end
            end
        end

        Scene.update(self)  -- runs all registered systems

        -- Check win/lose conditions during play mode
        if not self.isPaused then
            local allHappy = true
            local allAngry = true
            local boidCount = 0

            for _, entity in ipairs(self.entities) do
                if entity.emotionalBattery then
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

            -- Win if all boids are happy (and there are boids)
            if allHappy and boidCount > 0 then
                GAME_WORLD:queueScene(WinScene(self.totalBoidCount, self.explosionsHappy, self.explosionsAngry))
                return
            end

            -- Lose if all boids are angry (and there are boids)
            if allAngry and boidCount > 0 then
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
        local gaugeWidth = 30  -- includes padding
        local frameSize = 10

        -- Draw bottom status bar (white background)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(0, SCREEN_HEIGHT - statusBarHeight, SCREEN_WIDTH, statusBarHeight)

        -- Draw status bar border
        gfx.setColor(gfx.kColorBlack)
        gfx.drawLine(0, SCREEN_HEIGHT - statusBarHeight, SCREEN_WIDTH, SCREEN_HEIGHT - statusBarHeight)

        -- Draw status bar text (emotion counts only)
        local statusY = SCREEN_HEIGHT - statusBarHeight + 10
        gfx.drawText("Happy: " .. happyCount .. "  Sad: " .. sadCount .. "  Angry: " .. angryCount, 10, statusY)

        -- Draw mode indicator in lower right (UI area)
        local modeText
        if self.currentMode == "influence" then
            modeText = self.isPaused and "Influencing" or "Mode: Influence"
        else  -- capture mode
            modeText = self.isPaused and "Capturing" or "Mode: Capture"
        end

        local textWidth = gfx.getTextSize(modeText)
        local boxPadding = 5  -- larger box
        local modeX = SCREEN_WIDTH - textWidth - 15
        local modeY = SCREEN_HEIGHT - statusBarHeight + 10

        -- Simple box with black text (same style for both states)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(modeX - boxPadding, modeY - 3, textWidth + boxPadding * 2, 20)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(modeX - boxPadding, modeY - 3, textWidth + boxPadding * 2, 20)
        gfx.drawText(modeText, modeX, modeY)

        -- Draw camera frame (size depends on mode)
        -- Influence mode: normal frame (40px inset)
        -- Capture mode: smaller frame (80px inset)
        local frameInset = (self.currentMode == "capture") and 80 or 40
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

        -- Show capture progress bar below center cross (when in capture mode and paused)
        if self.currentMode == "capture" and self.isPaused and self.captureProgress > 0 then
            local progBarWidth = 80
            local progBarHeight = 6
            local progBarX = centerX - progBarWidth / 2
            local progBarY = centerY + 15  -- below the cross

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
