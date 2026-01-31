# 🎵 Playdate Audio Tutorial

This guide explains how to use sound effects and music in your Playdate game using our ECS architecture.

---

## 📚 Table of Contents

1. [Audio Basics](#audio-basics)
2. [Sound Effects (SamplePlayer)](#sound-effects-sampleplayer)
3. [Background Music (FilePlayer)](#background-music-fileplayer)
4. [Synthesizer (No Files Needed)](#synthesizer-no-files-needed)
5. [Using Audio in ECS](#using-audio-in-ecs)
6. [Complete Examples](#complete-examples)

---

## Audio Basics

### Playdate Audio Rules
- **Formats**: WAV and AIFF only (NO MP3, NO OGG)
- **Paths**: Never include file extension in code
  - ✅ `"sfx/jump"`
  - ❌ `"sfx/jump.wav"`
- **Location**: Audio files go in `source/sfx/` and `source/music/`

### Two Types of Players

| Type | Use Case | Memory | Example |
|------|----------|--------|---------|
| **SamplePlayer** | Short sound effects | Loaded into RAM | Jump, hit, click |
| **FilePlayer** | Background music | Streamed from disk | Theme, ambient |

---

## Sound Effects (SamplePlayer)

Use `sampleplayer` for **short sounds** that play frequently. They load entirely into memory for instant playback.

### Basic Usage

```lua
-- Create a sound effect player
local jumpSound = playdate.sound.sampleplayer.new("sfx/player/jump")

-- Play once
jumpSound:play()

-- Play and repeat 3 times (total 4 plays)
jumpSound:play(3)

-- Loop forever
jumpSound:play(0)

-- Stop playback
jumpSound:stop()

-- Check if playing
if jumpSound:isPlaying() then
    print("Sound is playing!")
end

-- Set volume (0.0 to 1.0)
jumpSound:setVolume(0.5)  -- 50% volume

-- Set playback rate (1.0 = normal, 2.0 = double speed, 0.5 = half speed)
jumpSound:setRate(1.5)
```

### Practical Example: Player Jump Sound

```lua
-- In your scene's onEnter() or entity creation:
local jumpSfx = playdate.sound.sampleplayer.new("sfx/player/jump")

-- Create player entity with audio
local player = Entity.new({
    transform = Transform(200, 120),
    velocity = Velocity(0, 0),
    playerInput = PlayerInput(3),
    audioSource = AudioSource(jumpSfx),  -- Attach sound to entity
})
```

---

## Background Music (FilePlayer)

Use `fileplayer` for **longer audio** like background music. It streams from disk, saving memory.

### Basic Usage

```lua
-- Create a music player
local bgMusic = playdate.sound.fileplayer.new("music/theme")

-- Play once
bgMusic:play()

-- Loop forever (most common for background music)
bgMusic:play(0)

-- Stop playback
bgMusic:stop()

-- Pause (can resume later)
bgMusic:pause()

-- Check if playing
if bgMusic:isPlaying() then
    print("Music is playing!")
end

-- Set volume
bgMusic:setVolume(0.3)  -- 30% volume for background

-- Fade out over 2 seconds, then stop
bgMusic:setVolume(0, 0, 2, function() bgMusic:stop() end)
```

### Practical Example: Scene Background Music

```lua
-- In MenuScene
function MenuScene()
    local scene = Scene.new("menu")
    
    -- Create music player
    local menuMusic = playdate.sound.fileplayer.new("music/menu_theme")
    
    function scene:onEnter()
        -- Start looping music when scene enters
        menuMusic:setVolume(0.4)
        menuMusic:play(0)  -- 0 = loop forever
    end
    
    function scene:onExit()
        -- Stop music when leaving scene
        menuMusic:stop()
    end
    
    function scene:update()
        -- Draw menu...
    end
    
    return scene
end
```

---

## Synthesizer (No Files Needed)

Perfect for **quick prototyping** or **procedural audio**. No sound files required!

### Available Waveforms

| Waveform | Constant | Sound Character |
|----------|----------|-----------------|
| Sine | `playdate.sound.kWaveSine` | Smooth, pure tone |
| Square | `playdate.sound.kWaveSquare` | Retro, 8-bit feel |
| Sawtooth | `playdate.sound.kWaveSawtooth` | Harsh, buzzy |
| Triangle | `playdate.sound.kWaveTriangle` | Softer than square |
| Noise | `playdate.sound.kWaveNoise` | White noise, static |

### Basic Usage

```lua
-- Create a synth with a waveform
local synth = playdate.sound.synth.new(playdate.sound.kWaveSquare)

-- Play a note
-- playNote(frequency, volume, duration)
synth:playNote(440, 0.5, 0.2)  -- A4 note, 50% volume, 0.2 seconds

-- Common frequencies (musical notes)
-- C4 = 261.63, D4 = 293.66, E4 = 329.63, F4 = 349.23
-- G4 = 392.00, A4 = 440.00, B4 = 493.88, C5 = 523.25
```

### Practical Examples

```lua
-- Quick beep for UI feedback
local uiBeep = playdate.sound.synth.new(playdate.sound.kWaveSquare)
uiBeep:playNote(880, 0.3, 0.05)  -- High short beep

-- Error/wrong sound
local errorSound = playdate.sound.synth.new(playdate.sound.kWaveSawtooth)
errorSound:playNote(200, 0.4, 0.3)  -- Low buzzy sound

-- Coin/pickup sound (quick ascending notes)
local coinSynth = playdate.sound.synth.new(playdate.sound.kWaveSine)
coinSynth:playNote(523, 0.3, 0.1)  -- C5
-- Use a timer to play the second note
playdate.timer.performAfterDelay(100, function()
    coinSynth:playNote(659, 0.3, 0.1)  -- E5
end)

-- Jump sound effect
local jumpSynth = playdate.sound.synth.new(playdate.sound.kWaveTriangle)
jumpSynth:playNote(300, 0.3, 0.15)
```

---

## Using Audio in ECS

Our ECS uses the `AudioSource` component and `AudioSystem` to manage sounds attached to entities.

### The AudioSource Component

```lua
-- From: source/game/components/audio.lua
function AudioSource(player)
    return {
        player = player,      -- sampleplayer or fileplayer instance
        shouldPlay = false,   -- set to true to trigger playback
    }
end
```

### How It Works

1. **Create** an entity with an `AudioSource` component
2. **Trigger** playback by setting `entity.audioSource.shouldPlay = true`
3. **AudioSystem** detects this, plays the sound, and resets the flag

### Example: Collision Sound

```lua
-- In CollisionSystem (source/game/systems/collision_system.lua)
CollisionSystem = System.new("collision", {"transform", "collider"}, function(entities, scene)
    for i, a in ipairs(entities) do
        for j, b in ipairs(entities) do
            if i < j and checkCollision(a, b) then
                -- Trigger sound on entity 'a' if it has audio
                if a.audioSource then
                    a.audioSource.shouldPlay = true
                end
            end
        end
    end
end)
```

### Creating an Audio-Only Entity

For background music or ambient sounds that don't need a position:

```lua
-- In GameScene:onEnter()
local bgMusicPlayer = playdate.sound.fileplayer.new("music/gameplay")
bgMusicPlayer:play(0)  -- Loop forever

-- Optional: Create as entity if you want system control
local musicEntity = Entity.new({
    audioSource = AudioSource(bgMusicPlayer),
})
scene:addEntity(musicEntity)
```

---

## Complete Examples

### Example 1: Player with Jump Sound

```lua
-- In game_scene.lua onEnter()

-- Load the sound
local jumpSfx = playdate.sound.sampleplayer.new("sfx/player/jump")

-- Create player with audio
local player = Entity.new({
    transform = Transform(200, 120),
    velocity = Velocity(0, 0),
    playerInput = PlayerInput(3),
    audioSource = AudioSource(jumpSfx),
})
scene:addEntity(player)
```

```lua
-- In player_system.lua
PlayerSystem = System.new("player", {"transform", "velocity", "playerInput"}, function(entities, scene)
    for _, e in ipairs(entities) do
        -- Jump when A is pressed
        if playdate.buttonJustPressed(playdate.kButtonA) then
            e.velocity.dy = -10  -- Jump velocity
            
            -- Trigger jump sound if entity has audio
            if e.audioSource then
                e.audioSource.shouldPlay = true
            end
        end
    end
end)
```

### Example 2: UI Menu with Synth Sounds

```lua
-- No audio files needed!
function MenuScene()
    local scene = Scene.new("menu")
    local selectedOption = 1
    local options = {"Start Game", "Options", "Credits"}
    
    -- Create synths for UI feedback
    local moveSynth = playdate.sound.synth.new(playdate.sound.kWaveSquare)
    local selectSynth = playdate.sound.synth.new(playdate.sound.kWaveSine)
    
    function scene:update()
        -- Navigate menu
        if playdate.buttonJustPressed(playdate.kButtonUp) then
            selectedOption = math.max(1, selectedOption - 1)
            moveSynth:playNote(600, 0.2, 0.05)  -- Short blip
        end
        
        if playdate.buttonJustPressed(playdate.kButtonDown) then
            selectedOption = math.min(#options, selectedOption + 1)
            moveSynth:playNote(500, 0.2, 0.05)  -- Slightly lower blip
        end
        
        -- Select option
        if playdate.buttonJustPressed(playdate.kButtonA) then
            selectSynth:playNote(880, 0.3, 0.1)  -- Confirmation sound
            
            if selectedOption == 1 then
                GAME_WORLD:queueScene(GameScene())
            end
        end
        
        -- Draw menu (simplified)
        local gfx = playdate.graphics
        gfx.clear()
        for i, opt in ipairs(options) do
            local prefix = (i == selectedOption) and "> " or "  "
            gfx.drawText(prefix .. opt, 150, 80 + (i * 30))
        end
    end
    
    return scene
end
```

### Example 3: Background Music Manager

```lua
-- A simple music manager you can add to lib/utils.lua or create as lib/music.lua

MusicManager = {}
MusicManager.current = nil

function MusicManager.play(path, volume, loop)
    -- Stop current music if playing
    if MusicManager.current and MusicManager.current:isPlaying() then
        MusicManager.current:stop()
    end
    
    -- Create and play new music
    MusicManager.current = playdate.sound.fileplayer.new(path)
    MusicManager.current:setVolume(volume or 0.5)
    MusicManager.current:play(loop and 0 or 1)
end

function MusicManager.stop()
    if MusicManager.current then
        MusicManager.current:stop()
    end
end

function MusicManager.fadeOut(duration)
    if MusicManager.current then
        MusicManager.current:setVolume(0, 0, duration or 1, function()
            MusicManager.current:stop()
        end)
    end
end

-- Usage in scenes:
-- MusicManager.play("music/menu_theme", 0.4, true)
-- MusicManager.fadeOut(2)
```

---

## 📁 Recommended Sound Files to Create

Put these files in your `source/Sounds/` folder:

### Sound Effects (sfx/)
| Path | Purpose | Duration |
|------|---------|----------|
| `sfx/player/jump.wav` | Player jump | 0.2s |
| `sfx/player/land.wav` | Player landing | 0.1s |
| `sfx/player/hurt.wav` | Player takes damage | 0.3s |
| `sfx/player/death.wav` | Player dies | 0.5s |
| `sfx/game/coin.wav` | Collect item | 0.2s |
| `sfx/game/explosion.wav` | Explosion | 0.4s |
| `sfx/ui/select.wav` | Menu select | 0.1s |
| `sfx/ui/confirm.wav` | Confirm action | 0.15s |
| `sfx/ui/back.wav` | Go back/cancel | 0.1s |

### Music (music/)
| Path | Purpose | Duration |
|------|---------|----------|
| `music/menu_theme.wav` | Main menu | 30-60s (loopable) |
| `music/gameplay.wav` | In-game music | 60-120s (loopable) |
| `music/gameover.wav` | Game over screen | 10-20s |

---

## 🎛️ Tips & Best Practices

1. **Use Synths for Prototyping**: Before adding real sound files, use synths to test audio feedback
2. **Keep SFX Short**: < 2 seconds for sampleplayer sounds
3. **Loop Music Seamlessly**: Edit your music files so the end flows into the beginning
4. **Mind the Volume**: Start at 0.3-0.5 volume, adjust based on mixing
5. **Mono is Fine**: Playdate's speaker is mono, save file size with mono audio
6. **Test on Device**: Audio may sound different on actual Playdate hardware

---

## 🔗 Quick Reference

```lua
-- SamplePlayer (SFX)
local sfx = playdate.sound.sampleplayer.new("Sounds/path")
sfx:play()  |  sfx:stop()  |  sfx:setVolume(0.5)  |  sfx:isPlaying()

-- FilePlayer (Music)
local music = playdate.sound.fileplayer.new("Sounds/path")
music:play(0)  |  music:stop()  |  music:pause()  |  music:setVolume(0.5)

-- Synth (Procedural)
local synth = playdate.sound.synth.new(playdate.sound.kWaveSquare)
synth:playNote(frequency, volume, duration)
-- Waveforms: kWaveSine, kWaveSquare, kWaveSawtooth, kWaveTriangle, kWaveNoise

-- ECS Integration
entity.audioSource = AudioSource(player)
entity.audioSource.shouldPlay = true  -- AudioSystem will play it
```

Happy sound designing! 🎵
