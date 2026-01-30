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

    function scene:onEnter()
        -- Register systems in execution order
        self:addSystem(PlayerSystem)
        self:addSystem(CrankSystem)
        self:addSystem(PhysicsSystem)
        self:addSystem(CollisionSystem)
        self:addSystem(AudioSystem)
        self:addSystem(RenderSystem)

        -- TODO: Create your game entities here
        --
        -- Example player entity:
        -- local player = Entity.new({
        --     transform = Transform(200, 120),
        --     velocity = Velocity(0, 0),
        --     playerInput = PlayerInput(3),
        --     sprite = SpriteComp(gfx.image.new("Images/player")),
        --     collider = Collider(16, 16),
        -- })
        -- self:addEntity(player)
        --
        -- Example enemy entity:
        -- local enemy = Entity.new({
        --     transform = Transform(100, 60),
        --     velocity = Velocity(1, 0),
        --     sprite = SpriteComp(gfx.image.new("Images/enemy")),
        --     collider = Collider(12, 12, 2),
        -- })
        -- self:addEntity(enemy)
        --
        -- Example crank-controlled entity:
        -- local dial = Entity.new({
        --     transform = Transform(200, 120),
        --     crankInput = CrankInput(),
        --     sprite = SpriteComp(gfx.image.new("Images/dial")),
        -- })
        -- self:addEntity(dial)
    end

    function scene:onExit()
        -- TODO: Clean up, save score, etc.
    end

    -- Runs all systems via the default Scene:update(), then draws UI.
    -- Replace this with your own game rendering once you have entities.
    function scene:update()
        Scene.update(self)  -- runs all registered systems

        -- Placeholder UI (replace with your game's HUD)
        gfx.drawTextAligned("*Game Scene*", 200, 110, kTextAlignment.center)
        gfx.drawTextAligned("Add entities in game_scene.lua:onEnter()", 200, 135, kTextAlignment.center)
    end

    return scene
end
