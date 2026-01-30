# CLAUDE.md

## Project Overview

Playdate console game built with Lua, using a lightweight ECS (Entity-Component-System) architecture. This is a game jam project for a team of 2-4 people. The codebase is designed so each team member works on separate files to avoid merge conflicts.

## Tech Stack

- **Platform**: Playdate (handheld console, 400x240 1-bit screen, 30 FPS)
- **Language**: Lua 5.4 with Playdate extensions (`+=`, `-=`, `*=`, `/=`)
- **Module system**: `import "path/file"` (NOT `require`). Everything is global scope.
- **Build tool**: `pdc` (Playdate compiler). In VS Code: `Ctrl+Shift+B`
- **Standard libraries**: No `io`, `os`, or `package`. Only Playdate SDK APIs.

## Architecture

### ECS Pattern

- **Entity** (`ecs/entity.lua`): Plain Lua table with `id`, `active` flag, and component data as named fields. Created via `Entity.new({ transform = Transform(x,y), ... })`.
- **System** (`ecs/system.lua`): Declares required components, receives only matching entities. Created via `System.new(name, {"comp1", "comp2"}, updateFn)`.
- **Scene** (`ecs/scene.lua`): Owns entities + systems. Has `onEnter()`/`onExit()` lifecycle hooks. Default `update()` runs all systems then cleans up dead entities. Simple scenes (menus) override `update()` directly.
- **World** (`ecs/world.lua`): Manages active scene. `GAME_WORLD` is the global instance. `queueScene()` defers transition to next frame.

### System Execution Order (set in game_scene.lua)

1. PlayerSystem (input)
2. CrankSystem (input)
3. PhysicsSystem (logic)
4. CollisionSystem (logic)
5. AudioSystem (output)
6. RenderSystem (output) -- always last

### Inter-System Communication

Systems never call each other. They communicate through component data:
- System A sets `entity.someComponent.flag = true`
- System B reads the flag on its next update

### Entity Lifecycle

- **Create**: `Entity.new({...})` then `scene:addEntity(entity)`
- **Destroy**: Set `entity.active = false` — auto-removed at end of frame
- **Query**: `scene:getEntitiesWith("componentName")` or check `entity.componentName ~= nil`

## File Organization Rules

- `main.lua` — **DO NOT MODIFY.** Minimal entrypoint: imports + boot. Only touch to add new `import` lines.
- `ecs/` — **DO NOT MODIFY.** Core engine, stable and complete.
- `components/` — One file per domain (`core.lua`, `input.lua`, `visual.lua`, `collision.lua`, `audio.lua`). Add new components at the bottom of the matching domain file. If no domain fits, create a new file and add its `import` to `main.lua`.
- `systems/` — One file per system. Each file has SDK reference comments at the top.
- `scenes/` — Scene constructors. `GameScene` uses the ECS loop; `MenuScene`/`GameOverScene` override `update()`.
- `lib/utils.lua` — Shared utilities.
- `Images/` — PNG assets. Load without extension: `gfx.image.new("Images/name")`
- `Sounds/` — WAV/AIFF only. Load without extension: `sampleplayer.new("Sounds/name")`

## Coding Conventions

- Components are **pure data** — constructor functions that return plain tables. No methods.
- Systems contain **all logic**. One file per system.
- Entities are created in scene `onEnter()` methods.
- Use `GAME_WORLD:queueScene(NewScene())` for scene transitions.
- Use the utilities from `lib/utils.lua`: `clamp()`, `lerp()`, `distance()`, `random_float()`, `SCREEN_WIDTH`, `SCREEN_HEIGHT`.

## When Generating Code

- Follow the exact pattern of existing system files: SDK reference block comment at top, then `System.new()` call.
- When creating a new system, also remind the user to add the `import` line to `main.lua` and register it in the scene's `onEnter()`.
- When creating a new component, add it to the matching file under `components/` (e.g., input-related → `components/input.lua`). If no domain file fits, create a new one and add its `import` to `main.lua`.
- When creating a new scene, follow the pattern in existing scene files: constructor function that returns a `Scene.new()` instance.
- Register new systems in `onEnter()` respecting execution order: input → logic → output (render last).
- Do not add `require` statements — Playdate uses `import`.
- Do not reference standard Lua libraries (`io`, `os`, `package`) — they don't exist on Playdate.
- Audio files must be WAV or AIFF. No MP3 or OGG.
- Image and audio paths use no file extension in code.

## Build & Run

```bash
# Compile
pdc source builds/GameName.pdx

# VS Code: Ctrl+Shift+B (Build and Run task)
```
