-- Playdate CoreLibs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"
import "CoreLibs/animation"

-- Utilities
import "lib/utils"
import "lib/resources"
import "lib/synth"

-- ECS Core
import "ecs/entity"
import "ecs/system"
import "ecs/scene"
import "ecs/world"

-- Game Components (one file per domain -- add new imports here as needed)
import "game/components/core"
import "game/components/input"
import "game/components/visual"
import "game/components/collision"
import "game/components/audio"
import "game/components/emotion"
import "game/components/boidvisual"

-- Game Systems (each file is independent -- safe to edit in parallel)
import "game/systems/camera_system"
import "game/systems/happiness_crank_system"
import "game/systems/capture_crank_system"
import "game/systems/emotional_battery_system"
import "game/systems/emotion_influence_system"
import "game/systems/boid_system"
import "game/systems/render_clear_system"
import "game/systems/render_background_system"
import "game/systems/render_sprite_system"
import "game/systems/render_boid_hp_system"
import "game/systems/render_captured_system"
import "game/systems/render_explosion_system"
import "game/systems/render_ui_system"
import "game/systems/physics_system"
import "game/systems/player_system"
import "game/systems/crank_system"
import "game/systems/collision_system"
import "game/systems/render_system"
import "game/systems/synth_system"

-- Scenes
import "scenes/menu_scene"
import "scenes/game_scene"
import "scenes/boid_scene"
import "scenes/win_scene"
import "scenes/lose_scene"
import "scenes/gameover_scene"
import "scenes/visualtest_scene"
import "scenes/test_audio_scene"
import "scenes/credits_scene"


-- Boot
GAME_WORLD = World.new()
GAME_WORLD:setScene(MenuScene())

function playdate.update()
    GAME_WORLD:update() -- Systems control render order
end
