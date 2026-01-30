--[[
    WORLD
    Manages the active scene and handles scene transitions.

    Usage:
        GAME_WORLD = World.new()
        GAME_WORLD:setScene(MenuScene())

        -- In playdate.update():
        GAME_WORLD:update()

        -- From anywhere (systems, scenes) to change scene:
        GAME_WORLD:queueScene(GameScene())
        -- The transition happens at the start of the next frame,
        -- so it's safe to call mid-update.
]]

World = {}
World.__index = World

function World.new()
    return setmetatable({
        currentScene = nil,
        _pendingScene = nil,
    }, World)
end

-- Immediately switch to a new scene (calls onExit/onEnter)
function World:setScene(scene)
    if self.currentScene and self.currentScene.onExit then
        self.currentScene:onExit()
    end
    self.currentScene = scene
    if scene.onEnter then
        scene:onEnter()
    end
end

-- Request a scene transition at the start of the next frame
function World:queueScene(scene)
    self._pendingScene = scene
end

function World:update()
    if self._pendingScene then
        self:setScene(self._pendingScene)
        self._pendingScene = nil
    end

    if self.currentScene then
        self.currentScene:update()
    end

    playdate.timer.updateTimers()
end
