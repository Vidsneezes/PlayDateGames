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

    -- Camera for scrolling world (viewport-sized for testing)
    scene.camera = {
        x = 0,
        y = 0,
        worldWidth = SCREEN_WIDTH,   -- 400 (same as viewport for testing)
        worldHeight = SCREEN_HEIGHT  -- 240 (same as viewport for testing)
    }

    -- Helper: Create temporary sprite for each emotion type
    local function createBoidSprite(emotionType)
        local img = gfx.image.new(16, 16, gfx.kColorWhite)
        gfx.lockFocus(img)
        gfx.setColor(gfx.kColorBlack)

        if emotionType == "happy" then
            -- Triangle (pointing up)
            gfx.fillPolygon(8, 2, 14, 14, 2, 14)
        elseif emotionType == "sad" then
            -- Circle
            gfx.fillCircleAtPoint(8, 8, 7)
        elseif emotionType == "angry" then
            -- Square
            gfx.fillRect(2, 2, 12, 12)
        end

        gfx.unlockFocus()
        return img
    end

    -- Helper: Spawn multiple boids with random positions and emotions
    local function spawnRandomBoids(scene, count)
        local worldW = scene.camera.worldWidth
        local worldH = scene.camera.worldHeight
        local spriteSize = 16
        local emotions = {"happy", "sad", "angry"}

        for i = 1, count do
            -- Random position (keeping sprite in bounds)
            local x = math.random(0, worldW - spriteSize)
            local y = math.random(0, worldH - spriteSize)

            -- Random emotion
            local emotionType = emotions[math.random(1, 3)]

            -- Create boid with appropriate component
            local boid = Entity.new({
                transform = Transform(x, y),
                velocity = Velocity(0, 0),
                boidsprite = BoidSpriteComp(boidRectangle, bubbleImage)
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
        self:addSystem(BoidSystem)
        self:addSystem(PhysicsSystem)
        self:addSystem(RenderSystem)
        self:addSystem(BoidRenderSystem)

        -- Spawn test boids
        -- ADJUST THIS NUMBER to test performance (3, 50, 100, etc.)
        local BOID_COUNT = 100
        spawnRandomBoids(self, BOID_COUNT)
    end

    function scene:onExit()
        -- Clean up if needed
    end

    function scene:update()
        Scene.update(self)  -- runs all registered systems

        -- Draw debug HUD
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("Boid Scene - Camera: (" .. math.floor(self.camera.x) .. ", " .. math.floor(self.camera.y) .. ")", 5, 5)
        gfx.drawText("Triangle=Happy, Circle=Sad, Square=Angry", 5, 220)
    end

    return scene
end
