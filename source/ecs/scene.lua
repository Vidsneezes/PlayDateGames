--[[
    SCENE
    A scene owns a set of entities and systems.
    Switching scenes swaps everything -- each scene is independent.

    Usage:
        function GameScene()
            local scene = Scene.new("game")

            function scene:onEnter()
                self:addSystem(PhysicsSystem)
                self:addSystem(RenderSystem)

                local player = Entity.new({ transform = Transform(200, 120) })
                self:addEntity(player)
            end

            function scene:onExit()
                -- cleanup if needed
            end

            return scene
        end

    For simple scenes (menus, game over), you can override update() directly:

        function scene:update()
            gfx.drawTextAligned("Press A", 200, 120, kTextAlignment.center)
            if playdate.buttonJustPressed(playdate.kButtonA) then
                GAME_WORLD:queueScene(GameScene())
            end
        end
]]

Scene = {}
Scene.__index = Scene

function Scene.new(name)
    local self = setmetatable({
        name = name or "unnamed",
        entities = {},
        systems = {},
    }, Scene)
    return self
end

function Scene:addEntity(entity)
    self.entities[#self.entities + 1] = entity
    return entity
end

function Scene:removeEntity(id)
    for i, entity in ipairs(self.entities) do
        if entity.id == id then
            entity.active = false
            return
        end
    end
end

function Scene:addSystem(system)
    self.systems[#self.systems + 1] = system
end

-- Find all entities that have a specific component
function Scene:getEntitiesWith(componentName)
    local result = {}
    for _, entity in ipairs(self.entities) do
        if entity.active and entity[componentName] then
            result[#result + 1] = entity
        end
    end
    return result
end

-- Default update: runs all systems, then cleans up destroyed entities.
-- Override this in simple scenes (menus, etc.) for custom behavior.
function Scene:update()
    for _, system in ipairs(self.systems) do
        if system.enabled then
            local matched = System.filter(system, self.entities)
            system.update(matched, self)
        end
    end

    -- Remove entities marked as inactive (active = false)
    for i = #self.entities, 1, -1 do
        if not self.entities[i].active then
            table.remove(self.entities, i)
        end
    end
end

-- Override these in your scene constructor
function Scene:onEnter() end
function Scene:onExit() end
