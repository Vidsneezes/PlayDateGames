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

    -- Camera for scrolling world (4x viewport area)
    scene.camera = {
        x = 0,
        y = 0,
        worldWidth = SCREEN_WIDTH * 2,   -- 800 (2x width = 4x area total)
        worldHeight = SCREEN_HEIGHT * 2  -- 480 (2x height = 4x area total)
    }

    -- Pause state (starts playing)
    scene.isPaused = false

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
        local spriteSize = 32  -- Updated to 32x32 for testing
        local emotions = {"happy", "sad", "angry"}

        for i = 1, count do
            -- Random position (keeping sprite in bounds)
            local x = math.random(0, worldW - spriteSize)
            local y = math.random(0, worldH - spriteSize)

            -- Random emotion
            local emotionType = emotions[math.random(1, 3)]

            -- Set initial battery based on emotion (max for their range)
            local initialBattery = 100
            if emotionType == "happy" then
                initialBattery = 100  -- Max for happy (61-100)
            elseif emotionType == "sad" then
                initialBattery = 60   -- Max for sad (31-60)
            elseif emotionType == "angry" then
                initialBattery = 30   -- Max for angry (0-30)
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
        self:addSystem(HappinessCrankSystem)     -- Read crank input first
        self:addSystem(EmotionalBatterySystem)   -- Update emotions after happiness changes
        self:addSystem(EmotionInfluenceSystem)   -- Proximity effects (comment out if too slow)
        self:addSystem(BoidSystem)               -- Update boid AI and sprites
        self:addSystem(RenderClearSystem)        -- Clear screen to white
        self:addSystem(RenderBackgroundSystem)   -- Draw grass tilemap
        self:addSystem(RenderSpriteSystem)       -- Draw boid sprites
        self:addSystem(RenderBoidHPSystem)       -- Draw HP bars on top of sprites
        -- self:addSystem(RenderUISystem)           -- Happiness gauge (DISABLED - using individual HP bars)

        -- Spawn test boids
        -- ADJUST THIS NUMBER to test performance
        local BOID_COUNT = 10  -- Small count for testing gameplay feel
        spawnRandomBoids(self, BOID_COUNT)
    end

    function scene:onExit()
        -- Clean up if needed
    end

    function scene:update()
        -- A button toggles pause
        if playdate.buttonJustPressed(playdate.kButtonA) then
            self.isPaused = not self.isPaused
        end

        if playdate.buttonJustPressed(playdate.kButtonB) then
            GAME_WORLD:queueScene(WinScene())
        end

        Scene.update(self)  -- runs all registered systems

        -- Check win condition: all boids are happy (battery > 60)
        -- Only check during play mode
        if not self.isPaused then
            local allHappy = true
            local boidCount = 0
            for _, entity in ipairs(self.entities) do
                if entity.emotionalBattery then
                    boidCount += 1
                    if entity.emotionalBattery.value <= 60 then
                        allHappy = false
                        break
                    end
                end
            end

            -- Win if all boids are happy (and there are boids)
            if allHappy and boidCount > 0 then
                GAME_WORLD:queueScene(WinScene())
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

        -- Draw pause state indicator in lower right (UI area)
        local pauseText = self.isPaused and "PAUSED" or "PLAYING"
        local textWidth = gfx.getTextSize(pauseText)
        local boxPadding = 5  -- larger box
        local pauseX = SCREEN_WIDTH - textWidth - 15
        local pauseY = SCREEN_HEIGHT - statusBarHeight + 10

        -- Simple box with black text (same style for both states)
        gfx.setColor(gfx.kColorWhite)
        gfx.fillRect(pauseX - boxPadding, pauseY - 3, textWidth + boxPadding * 2, 20)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawRect(pauseX - boxPadding, pauseY - 3, textWidth + boxPadding * 2, 20)
        gfx.drawText(pauseText, pauseX, pauseY)

        -- Draw camera frame (smaller and centered, ignoring gauge for centering)
        local frameInset = 40  -- distance from edges (larger = smaller frame)
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
    end

    return scene
end
