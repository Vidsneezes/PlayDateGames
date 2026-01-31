--[[
    GAME SCENE
    Main gameplay scene. Uses the full ECS loop.

    This is where you:
    1. Register which systems run (and in what order)
    2. Create your game entities

    System order matters:
        - Input systems first (player, crank) -- read what the player wants
        - Logic systems next (physics, collision) -- simulate the world
        - Output systems last (audio, render) -- present the result
]]

local gfx = playdate.graphics

function VisualTestScene()
    local scene = Scene.new("game")

    -- Camera for scrolling world (accessible by all systems)
    scene.camera = {
        x = 0,           -- current viewport top-left X
        y = 0,           -- current viewport top-left Y
        worldWidth = 1200,   -- total world width
        worldHeight = 800    -- total world height
    }

    function scene:onEnter()
        -- Register systems in execution order
        self:addSystem(CameraSystem)  -- camera control (input)
        self:addSystem(PlayerSystem)
        self:addSystem(CrankSystem)
        self:addSystem(PhysicsSystem)
        self:addSystem(CollisionSystem)
        self:addSystem(AudioSystem)
        self:addSystem(RenderSystem)
        self:addSystem(BoidRenderSystem)

        local boidtest = Entity.new({
            transform = Transform(100, 80),
            boidsprite = BoidSpriteComp(bodyImage, bubbleImage)
        })
        self:addEntity(boidtest)
    end

    function scene:onExit()
        -- TODO: Clean up, save score, etc.
    end

    function scene:update()
        Scene.update(self)  -- runs all registered systems

        -- Draw HUD (camera info for debugging)
        gfx.setColor(gfx.kColorBlack)
        gfx.drawText("Camera: (" .. math.floor(self.camera.x) .. ", " .. math.floor(self.camera.y) .. ")", 5, 5)
        gfx.drawText("World: " .. self.camera.worldWidth .. "x" .. self.camera.worldHeight, 5, 20)
        gfx.drawText("Use arrow keys to move camera", 5, 220)
    end

    return scene
end
