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

function GameScene()
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

        -- Camera test: Create simple marker sprites around the world
        -- (These help visualize camera movement)
        local function createMarker(size)
            local img = gfx.image.new(size, size, gfx.kColorWhite)
            gfx.lockFocus(img)
            gfx.setColor(gfx.kColorBlack)
            gfx.fillRect(0, 0, size, size)
            gfx.unlockFocus()
            return img
        end

        -- Markers at corners and center of world
        local markers = {
            {x = 50, y = 50},         -- top-left
            {x = 1150, y = 50},       -- top-right
            {x = 600, y = 400},       -- center
            {x = 50, y = 750},        -- bottom-left
            {x = 1150, y = 750},      -- bottom-right
        }

        for _, pos in ipairs(markers) do
            local marker = Entity.new({
                transform = Transform(pos.x, pos.y),
                sprite = SpriteComp(createMarker(20, 20))
            })
            self:addEntity(marker)
        end
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
