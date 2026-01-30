# Playdate Game Jam Template

A modular game template for the [Playdate](https://play.date/) console, built around a lightweight **ECS (Entity-Component-System)** architecture. Designed for teams of 2-4 people to work in parallel with minimal merge conflicts.

---

## Setup (per platform)

### 1. Install the Playdate SDK

Download from [play.date/dev](https://play.date/dev/) and install for your OS.

#### Windows

1. Run the SDK installer — it installs to `C:\Users\<you>\Documents\PlaydateSDK` by default
2. The installer sets the `PLAYDATE_SDK_PATH` environment variable automatically
3. Verify in a terminal: `echo %PLAYDATE_SDK_PATH%` should print the path
4. Verify the compiler: `pdc --version` should print a version number

If `pdc` is not found, add `%PLAYDATE_SDK_PATH%\bin` to your `PATH`:
- Settings > System > About > Advanced system settings > Environment Variables
- Edit `Path` under User variables, add `%PLAYDATE_SDK_PATH%\bin`

#### macOS

1. Open the `.pkg` installer — it installs to `~/Developer/PlaydateSDK`
2. The installer sets `PLAYDATE_SDK_PATH` automatically
3. Verify in Terminal: `echo $PLAYDATE_SDK_PATH` should print the path
4. Verify the compiler: `pdc --version`

If `pdc` is not found, add to your `~/.zshrc`:
```bash
export PLAYDATE_SDK_PATH="$HOME/Developer/PlaydateSDK"
export PATH="$PLAYDATE_SDK_PATH/bin:$PATH"
```
Then run `source ~/.zshrc`.

#### Linux

1. Download and extract the SDK (e.g., to `/opt/playdate-sdk/`)
2. Set the environment variable in your shell config:

   **bash/zsh** (`~/.bashrc` or `~/.zshrc`):
   ```bash
   export PLAYDATE_SDK_PATH="/opt/playdate-sdk"
   export PATH="$PLAYDATE_SDK_PATH/bin:$PATH"
   ```

   **fish** (`~/.config/fish/config.fish`):
   ```fish
   set -gx PLAYDATE_SDK_PATH /opt/playdate-sdk
   fish_add_path $PLAYDATE_SDK_PATH/bin
   ```

3. Reload your shell and verify:
   ```bash
   pdc --version       # should print version
   echo $PLAYDATE_SDK_PATH   # should print the SDK path
   ```

4. **Important**: Make sure `$PLAYDATE_SDK_PATH` points to the directory that contains `CoreLibs/`, `bin/`, and `Examples/`. If it doesn't, `pdc` won't find the Playdate libraries and the build will fail with `No such file: CoreLibs/...`.

### 2. Install VS Code Extensions

Open the project in VS Code. It will prompt you to install recommended extensions:
- **Sumneko Lua** — Lua language support with autocomplete
- **Playdate Debug** — build tasks and debugger integration

Accept the recommendations, or install them manually from the Extensions panel.

### 3. Build & Run

1. Open the project in VS Code
2. Press `Ctrl+Shift+B` (Windows/Linux) or `Cmd+Shift+B` (Mac)
3. This compiles the project and launches the Playdate Simulator
4. The game starts at the Menu Scene

### Manual Build (command line)

```bash
pdc source builds/YourGame.pdx
```

Then open the `.pdx` folder with the Playdate Simulator:
- **Windows**: `%PLAYDATE_SDK_PATH%\bin\PlaydateSimulator.exe builds\YourGame.pdx`
- **macOS**: `open -a "Playdate Simulator" builds/YourGame.pdx`
- **Linux**: `$PLAYDATE_SDK_PATH/bin/PlaydateSimulator builds/YourGame.pdx`

---

## Project Structure

```
source/
├── main.lua                    -- Entrypoint (~40 lines). Imports everything, boots the world.
│                                  DO NOT EDIT during the jam.
│
├── ecs/                        -- ECS core engine (~150 lines total)
│   ├── entity.lua              -- Entity: ID + component data as named table fields
│   ├── system.lua              -- System: declares required components, runs update logic
│   ├── scene.lua               -- Scene: owns entities + systems, lifecycle hooks
│   └── world.lua               -- World: manages the active scene + transitions
│
├── components.lua              -- All component constructors (Transform, Velocity, etc.)
│
├── systems/                    -- One file per system. Each teammate owns their file(s).
│   ├── player_system.lua       -- Button/d-pad input handling
│   ├── crank_system.lua        -- Crank input handling
│   ├── physics_system.lua      -- Applies velocity to position
│   ├── collision_system.lua    -- Collision detection between entities
│   ├── audio_system.lua        -- Sound effects and music playback
│   └── render_system.lua       -- Drawing sprites, images, and UI
│
├── scenes/                     -- Game scenes (menu, gameplay, game over)
│   ├── menu_scene.lua          -- Title screen
│   ├── game_scene.lua          -- Main gameplay (registers systems, creates entities)
│   └── gameover_scene.lua      -- Game over screen
│
├── lib/
│   └── utils.lua               -- Shared helpers: clamp, lerp, distance, random_float, etc.
│
├── Images/                     -- Image assets (.png)
├── Sounds/                     -- Audio assets (.wav, .aiff)
└── Data.json                   -- Game configuration (loaded via loadConfig)
```

---

## Architecture

### ECS in 30 Seconds

```
Entity  = a table with component data     { id=1, transform={x=0,y=0}, velocity={dx=1,dy=0} }

System  = processes entities that have specific components
          PhysicsSystem requires "transform" + "velocity"
          RenderSystem  requires "transform" + "sprite"

Scene   = owns a set of entities and systems, updates each frame
          GameScene registers all systems and creates game entities
          MenuScene overrides update() for simple direct drawing

World   = manages the active scene, handles transitions between scenes
```

### Data Flow (every frame)

```
playdate.update()
  └─ GAME_WORLD:update()
       ├─ Apply pending scene transition (if any)
       └─ currentScene:update()
            ├─ PlayerSystem.update(entities with playerInput)
            ├─ CrankSystem.update(entities with crankInput)
            ├─ PhysicsSystem.update(entities with transform + velocity)
            ├─ CollisionSystem.update(entities with transform + collider)
            ├─ AudioSystem.update(entities with audioSource)
            ├─ RenderSystem.update(entities with transform + sprite)  ← always last
            └─ Clean up entities where active == false
```

**System order matters.** Input first, logic second, rendering last. This order is set in `game_scene.lua:onEnter()`.

---

## How-To Guide

### Creating an Entity

Entities are created in a scene's `onEnter()` method (usually `game_scene.lua`):

```lua
function scene:onEnter()
    local player = Entity.new({
        transform = Transform(200, 120),
        velocity = Velocity(0, 0),
        playerInput = PlayerInput(3),
        sprite = SpriteComp(gfx.image.new("Images/player")),
        collider = Collider(16, 16),
    })
    self:addEntity(player)
end
```

An entity is just a table. Components are named fields. You pick which components an entity has based on what it needs to do.

### Adding a New Component

Open `components.lua` and add a constructor function at the bottom:

```lua
function Stamina(amount)
    return {
        current = amount or 100,
        max = amount or 100,
        regenRate = 1,
    }
end
```

Then use it when creating entities: `stamina = Stamina(50)`

### Creating a New System

Create a new file in `systems/`. The system declares what components it needs:

```lua
-- systems/stamina_system.lua
StaminaSystem = System.new("stamina", {"stamina"}, function(entities, scene)
    for _, e in ipairs(entities) do
        e.stamina.current = math.min(
            e.stamina.current + e.stamina.regenRate,
            e.stamina.max
        )
    end
end)
```

Then:
1. Add `import "systems/stamina_system"` in `main.lua` (in the systems section)
2. Add `self:addSystem(StaminaSystem)` in your scene's `onEnter()`

> If using Claude Code, run `/new-system stamina` to generate the boilerplate automatically.

### Creating a New Scene

Create a new file in `scenes/`. For simple scenes (menus, dialogs), override `update()` directly:

```lua
-- scenes/pause_scene.lua
local gfx = playdate.graphics

function PauseScene()
    local scene = Scene.new("pause")

    function scene:update()
        gfx.clear(gfx.kColorWhite)
        gfx.drawTextAligned("*PAUSED*", 200, 100, kTextAlignment.center)
        if playdate.buttonJustPressed(playdate.kButtonB) then
            GAME_WORLD:queueScene(GameScene())
        end
    end

    return scene
end
```

For gameplay scenes, use the default `Scene:update()` which runs the full ECS loop — just register systems in `onEnter()`.

Then:
1. Add `import "scenes/pause_scene"` in `main.lua` (in the scenes section)

> If using Claude Code, run `/new-scene pause` to generate the boilerplate automatically.

### Changing Scenes

From anywhere (systems, scenes, callbacks):

```lua
GAME_WORLD:queueScene(GameOverScene())
```

The transition happens at the start of the next frame, so it's safe to call mid-update.

### Destroying an Entity

```lua
entity.active = false
```

The scene automatically removes inactive entities at the end of each frame.

### Inter-System Communication

Systems never call each other directly. They communicate through component data:

1. `CollisionSystem` detects a hit, sets `entity.audioSource.shouldPlay = true`
2. `AudioSystem` sees the flag, plays the sound, resets it to `false`

This keeps systems decoupled and files independent.

### Querying Entities

From within a system, you can use the `scene` parameter:

```lua
MySystem = System.new("my", {"transform"}, function(entities, scene)
    -- 'entities' = only those matching this system's required components
    -- scene:getEntitiesWith("health") = all entities with a health component
    -- scene.entities = ALL entities in the scene
end)
```

---

## Team Workflow

### Merge Conflict Avoidance

Each person should primarily edit their own files:

| Role | Primary Files |
|------|---------------|
| Player controls | `systems/player_system.lua` |
| Crank mechanics | `systems/crank_system.lua` |
| Audio / Music | `systems/audio_system.lua`, `Sounds/*` |
| Rendering / UI | `systems/render_system.lua` |
| Collision | `systems/collision_system.lua` |
| Physics | `systems/physics_system.lua` |
| Level / entity design | `scenes/game_scene.lua` |

**Shared files** (coordinate before editing):
- `components.lua` — add new components at the **bottom** of the file
- `scenes/game_scene.lua` — entity creation in `onEnter()`
- `main.lua` — only to add new `import` lines (append to the relevant section)

**Never edit during the jam:**
- `ecs/*` — the ECS core is stable and complete

### Git Tips

```bash
# Before starting work
git pull

# Work on your own branch
git checkout -b feature/crank-aiming

# Commit often
git add systems/crank_system.lua
git commit -m "Add crank aiming with dead zone"

# Merge back
git checkout main
git pull
git merge feature/crank-aiming
```

### SDK Reference

Each system file has a **Playdate SDK Quick Reference** comment block at the top with the most relevant API functions. Open the system file you're working on and read the top section — it has everything you need.

---

## Playdate Quick Reference

| Property | Value |
|----------|-------|
| Screen size | 400 x 240 pixels |
| Color depth | 1-bit (black and white only) |
| Default FPS | 30 |
| Inputs | D-pad, A button, B button, Crank, Accelerometer |
| Audio formats | WAV, AIFF (no MP3, no OGG) |
| Lua version | 5.4 with Playdate extensions (`+=`, `-=`, `*=`, `/=`) |
| Module system | `import "path/file"` (not `require`) — no `.lua` extension |

### Loading Assets

```lua
-- Images (no file extension, relative to source/)
local img = playdate.graphics.image.new("Images/player")

-- Sounds (no file extension)
local sfx = playdate.sound.sampleplayer.new("Sounds/jump")      -- short SFX
local music = playdate.sound.fileplayer.new("Sounds/bgmusic")    -- streamed music
```

### Utility Functions (from lib/utils.lua)

```lua
clamp(val, min, max)          -- clamp value to range
lerp(a, b, t)                -- linear interpolation (t = 0..1)
distance(x1, y1, x2, y2)     -- euclidean distance
random_float(min, max)        -- random float in range
setBackground("Images/bg")   -- set fullscreen background image
loadConfig("Data")            -- load JSON config file

SCREEN_WIDTH   -- 400
SCREEN_HEIGHT  -- 240
```

---

## Available Components

| Component | Fields | Used by |
|-----------|--------|---------|
| `Transform(x, y, rotation)` | x, y, rotation | Most systems |
| `Velocity(dx, dy)` | dx, dy | PhysicsSystem |
| `SpriteComp(image)` | image, visible | RenderSystem |
| `PlayerInput(speed)` | speed | PlayerSystem |
| `CrankInput()` | angle, change | CrankSystem |
| `Collider(w, h, group)` | width, height, group | CollisionSystem |
| `AudioSource(player)` | player, shouldPlay | AudioSystem |
| `Health(hp)` | current, max | Your systems |
