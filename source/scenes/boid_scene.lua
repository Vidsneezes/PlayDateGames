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

    function scene:onEnter()
        -- Register systems in execution order
        self:addSystem(CameraSystem)
        self:addSystem(BoidSystem)
        self:addSystem(PhysicsSystem)
        self:addSystem(RenderSystem)

        -- Create 3 test boids with different emotions
        -- Positioned for viewport-sized world (400x240)
        local boid1 = Entity.new({
            transform = Transform(100, 60),  -- top-left quadrant (happy)
            velocity = Velocity(0, 0),
            happyBoid = HappyBoid(),  -- uses default speed (1.5)
            sprite = SpriteComp(createBoidSprite("happy"))
        })
        self:addEntity(boid1)

        local boid2 = Entity.new({
            transform = Transform(300, 180),  -- bottom-right quadrant (sad)
            velocity = Velocity(0, 0),
            sadBoid = SadBoid(),  -- uses default speed (1.0)
            sprite = SpriteComp(createBoidSprite("sad"))
        })
        self:addEntity(boid2)

        local boid3 = Entity.new({
            transform = Transform(350, 80),  -- top-right area (angry)
            velocity = Velocity(0, 0),
            angryBoid = AngryBoid(),  -- uses default speed (2.0) and detection range
            sprite = SpriteComp(createBoidSprite("angry"))
        })
        self:addEntity(boid3)
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
