--[[
    AUDIO SNIPPETS - Copy & Paste Examples
    Quick reference for common audio patterns in your Playdate game.

    Copy these snippets into your scenes or systems as needed!
]]

-- ============================================================
-- SNIPPET 1: Quick Sound Effect (No ECS)
-- Use this for simple, one-off sounds
-- ============================================================

-- Option A: Load and play immediately
local function playJumpSound()
    local sfx = playdate.sound.sampleplayer.new("sfx/player/jump")
    sfx:play()
end

-- Option B: Pre-load for efficiency (better for repeated sounds)
local jumpSfx = playdate.sound.sampleplayer.new("sfx/player/jump")
local function playPreloadedJump()
    jumpSfx:play()
end


-- ============================================================
-- SNIPPET 2: Background Music with Loop
-- Use in scene:onEnter()
-- ============================================================

local bgMusic = nil

local function startBackgroundMusic()
    bgMusic = playdate.sound.fileplayer.new("music/gameplay")
    bgMusic:setVolume(0.4) -- 40% volume
    bgMusic:play(0)        -- 0 = loop forever
end

local function stopBackgroundMusic()
    if bgMusic then
        bgMusic:stop()
    end
end

local function fadeOutMusic(durationSeconds)
    if bgMusic then
        bgMusic:setVolume(0, 0, durationSeconds, function()
            bgMusic:stop()
        end)
    end
end


-- ============================================================
-- SNIPPET 3: Synth Sounds (No Files Needed!)
-- Great for prototyping or retro feel
-- ============================================================

-- UI Sounds
local function uiBlip()
    local synth = playdate.sound.synth.new(playdate.sound.kWaveSquare)
    synth:playNote(600, 0.2, 0.05)
end

local function uiConfirm()
    local synth = playdate.sound.synth.new(playdate.sound.kWaveSine)
    synth:playNote(880, 0.3, 0.1)
end

local function uiError()
    local synth = playdate.sound.synth.new(playdate.sound.kWaveSawtooth)
    synth:playNote(200, 0.4, 0.2)
end

-- Game Sounds
local function jumpBeep()
    local synth = playdate.sound.synth.new(playdate.sound.kWaveTriangle)
    synth:playNote(400, 0.3, 0.1)
end

local function coinCollect()
    local synth = playdate.sound.synth.new(playdate.sound.kWaveSine)
    synth:playNote(523, 0.3, 0.08)     -- C5
    playdate.timer.performAfterDelay(80, function()
        synth:playNote(659, 0.3, 0.08) -- E5
    end)
end

local function explosionNoise()
    local synth = playdate.sound.synth.new(playdate.sound.kWaveNoise)
    synth:playNote(100, 0.5, 0.3)
end


-- ============================================================
-- SNIPPET 4: Entity with Audio (ECS Pattern)
-- Use with AudioSource component
-- ============================================================

--[[
-- In scene:onEnter()
local playerSfx = playdate.sound.sampleplayer.new("sfx/player/jump")

local player = Entity.new({
    transform = Transform(200, 120),
    velocity = Velocity(0, 0),
    playerInput = PlayerInput(3),
    audioSource = AudioSource(playerSfx),  -- Add audio component
})
scene:addEntity(player)

-- Then in a system, trigger the sound:
if shouldPlaySound then
    entity.audioSource.shouldPlay = true  -- AudioSystem handles playback
end
]]


-- ============================================================
-- SNIPPET 5: Complete Menu Scene with Audio
-- Copy this as a starting point for audio in menus
-- ============================================================

--[[
function AudioMenuScene()
    local scene = Scene.new("audio_menu")
    local selectedItem = 1
    local menuItems = {"Play", "Settings", "Quit"}

    -- Synths for menu sounds
    local moveSynth = playdate.sound.synth.new(playdate.sound.kWaveSquare)
    local selectSynth = playdate.sound.synth.new(playdate.sound.kWaveSine)

    -- Background music
    local menuMusic = nil

    function scene:onEnter()
        menuMusic = playdate.sound.fileplayer.new("music/menu_theme")
        menuMusic:setVolume(0.3)
        menuMusic:play(0)  -- Loop
    end

    function scene:onExit()
        if menuMusic then menuMusic:stop() end
    end

    function scene:update()
        local gfx = playdate.graphics

        -- Input handling
        if playdate.buttonJustPressed(playdate.kButtonUp) then
            if selectedItem > 1 then
                selectedItem = selectedItem - 1
                moveSynth:playNote(600, 0.2, 0.05)
            end
        end

        if playdate.buttonJustPressed(playdate.kButtonDown) then
            if selectedItem < #menuItems then
                selectedItem = selectedItem + 1
                moveSynth:playNote(500, 0.2, 0.05)
            end
        end

        if playdate.buttonJustPressed(playdate.kButtonA) then
            selectSynth:playNote(880, 0.3, 0.1)
            -- Handle selection...
        end

        -- Draw
        gfx.clear()
        for i, item in ipairs(menuItems) do
            local prefix = (i == selectedItem) and "> " or "  "
            gfx.drawText(prefix .. item, 160, 80 + (i * 30))
        end
    end

    return scene
end
]]


-- ============================================================
-- SNIPPET 6: Musical Note Frequencies
-- Reference for synth:playNote()
-- ============================================================

local NOTE_FREQUENCIES = {
    -- Octave 3
    C3 = 130.81,
    D3 = 146.83,
    E3 = 164.81,
    F3 = 174.61,
    G3 = 196.00,
    A3 = 220.00,
    B3 = 246.94,

    -- Octave 4 (Middle)
    C4 = 261.63,
    D4 = 293.66,
    E4 = 329.63,
    F4 = 349.23,
    G4 = 392.00,
    A4 = 440.00,
    B4 = 493.88,

    -- Octave 5
    C5 = 523.25,
    D5 = 587.33,
    E5 = 659.25,
    F5 = 698.46,
    G5 = 783.99,
    A5 = 880.00,
    B5 = 987.77,

    -- Octave 6
    C6 = 1046.50,
    D6 = 1174.66,
    E6 = 1318.51,
}

-- Usage: synth:playNote(NOTE_FREQUENCIES.A4, 0.5, 0.2)
