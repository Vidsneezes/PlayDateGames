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
        self:addSystem(BoidSystem)
        -- self:addSystem(PhysicsSystem) -- BoidSystem handles physics for boids now
        self:addSystem(RenderSystem) -- BoidSystem handles rendering for boids now
        self:addSystem(HappinessUISystem)        -- Draw UI last

        -- Spawn test boids
        -- ADJUST THIS NUMBER to test performance
        local BOID_COUNT = 10  -- Small count for testing gameplay feel
        spawnRandomBoids(self, BOID_COUNT)
    end

    function scene:onExit()
        -- Clean up if needed
    end

    function scene:update()
        Scene.update(self)  -- runs all registered systems

        -- Reset game with A or B button
        if playdate.buttonJustPressed(playdate.kButtonA) or playdate.buttonJustPressed(playdate.kButtonB) then
            GAME_WORLD:queueScene(BoidScene())
            return
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

        -- Draw camera frame visualization (playable area with padding for UI)
        gfx.setColor(gfx.kColorBlack)
        local frameSize = 10  -- size of corner markers
        local padLeft = 10
        local padTop = 10
        local padBottom = 10
        local padRight = 35  -- extra padding for happiness bar on right

        -- Playable area boundaries
        local playLeft = padLeft
        local playTop = padTop
        local playRight = SCREEN_WIDTH - padRight
        local playBottom = SCREEN_HEIGHT - padBottom

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

        -- Draw debug HUD
        gfx.drawText("Camera: (" .. math.floor(self.camera.x) .. ", " .. math.floor(self.camera.y) .. ")", 5, 5)
        gfx.drawText("Happy: " .. happyCount .. "  Sad: " .. sadCount .. "  Angry: " .. angryCount, 5, 220)
        gfx.drawText("Press A or B to reset", SCREEN_WIDTH - 120, 5)
    end

    return scene
end
