-- Playdate CoreLibs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"

-- Utilities
import "lib/utils"

-- ECS Core
import "ecs/entity"
import "ecs/system"
import "ecs/scene"
import "ecs/world"

-- Components (one file per domain -- add new imports here as needed)
import "components/core"
import "components/input"
import "components/visual"
import "components/collision"
import "components/audio"

-- Systems (each file is independent -- safe to edit in parallel)
import "systems/camera_system"
import "systems/physics_system"
import "systems/player_system"
import "systems/crank_system"
import "systems/collision_system"
import "systems/audio_system"
import "systems/render_system"

-- Scenes
import "scenes/menu_scene"
import "scenes/game_scene"
import "scenes/gameover_scene"

-- Boot
GAME_WORLD = World.new()
GAME_WORLD:setScene(MenuScene())

function playdate.update()
    GAME_WORLD:update()
end
