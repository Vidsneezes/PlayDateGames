--[[
    SOUND BANK (ADVANCED)
    - Reactive Music Sequencer (Multi-track)
    - Polyphonic SFX Pool
]]

local pd = playdate
local snd = pd.sound

SoundBank = {}

-- ============================================================
-- 1. SFX POOL (Polyphonic)
-- ============================================================
local SFX_VOICES = 4
local sfxPool = {}
local sfxIndex = 1

-- Create a pool of generic synths we can reconfigure on the fly
for i = 1, SFX_VOICES do
    table.insert(sfxPool, snd.synth.new(snd.kWaveSquare))
end

function SoundBank.playSfx(name)
    -- Cycle through pool (Round-robin)
    local synth = sfxPool[sfxIndex]
    sfxIndex = (sfxIndex % SFX_VOICES) + 1

    -- Stop previous sound if any
    if synth:isPlaying() then synth:stop() end

    -- Configure synth based on sound name
    if name == "jump" then
        synth:setWaveform(snd.kWaveTriangle)
        synth:setAttack(0.01)
        synth:setDecay(0.1)
        synth:setSustain(0.1)
        synth:setRelease(0.1)
        synth:playNote(300, 0.5, 0.2)
    elseif name == "coin" then
        synth:setWaveform(snd.kWaveSine)
        synth:setAttack(0.0)
        synth:setDecay(0.1)
        synth:setSustain(0.0)
        synth:setRelease(0.0)
        -- Quick arpeggio manually? For pool simplicity, just one note high
        synth:playNote(1000, 0.3, 0.1)
    elseif name == "explosion" then
        synth:setWaveform(snd.kWaveNoise)
        synth:setAttack(0.01)
        synth:setDecay(0.3)
        synth:setSustain(0.0)
        synth:setRelease(0.2)
        synth:playNote(50, 0.6, 0.4)
    elseif name == "hit" then
        synth:setWaveform(snd.kWaveSawtooth)
        synth:setAttack(0.01)
        synth:setDecay(0.1)
        synth:setSustain(0.0)
        synth:setRelease(0.1)
        synth:playNote(150, 0.5, 0.15)
    end
end

-- ============================================================
-- 2. MUSIC SEQUENCER (Multi-Track)
-- ============================================================
local musicState = {
    isPlaying = false,
    timer = nil,
    step = 1,
    tempo = 150, -- ms per step (approx 100 BPM for 16th notes)
    tracks = {
        bass = { synth = snd.synth.new(snd.kWaveTriangle), pattern = {}, volume = 0 },
        drums = { synth = snd.synth.new(snd.kWaveNoise), pattern = {}, volume = 0 },
        melody = { synth = snd.synth.new(snd.kWaveSquare), pattern = {}, volume = 0 }, -- Start Muted
    }
}

-- Init Instruments
musicState.tracks.bass.synth:setVolume(0.9)
musicState.tracks.drums.synth:setVolume(0.6)
musicState.tracks.melody.synth:setVolume(0.5)

-- SEQUENCER LOGIC
local function stepSequencer()
    if not musicState.isPlaying then return end

    local currentStep = musicState.step

    -- Process each track
    for name, track in pairs(musicState.tracks) do
        local note = track.pattern[currentStep]

        -- Check if track is active (volume > 0) and has a note
        if note and note > 0 and track.volume > 0 then
            -- Special handling for drums
            if name == "drums" then
                track.synth:setDecay(0.05)
                track.synth:playNote(100, track.volume * 0.8, 0.05)
            else
                -- Tonal instruments
                track.synth:playNote(note, track.volume * 0.5, 0.15)
            end
        end
    end

    -- Advance Step (Loop 16 steps)
    musicState.step = (currentStep % 16) + 1

    -- Next Tick
    musicState.timer = pd.timer.performAfterDelay(musicState.tempo, stepSequencer)
end

-- PATTERN DEFINITIONS
function SoundBank.playMusicInternal(trackName)
    SoundBank.stopMusic()

    if trackName == "theme" then
        -- 16-step patterns (0 = rest)

        -- Funky Bassline (Triangle)
        musicState.tracks.bass.pattern = {
            220, 0, 220, 0, 261, 0, 196, 0, -- A3, C4, G3
            220, 0, 0, 0, 220, 0, 293, 196
        }

        -- Hi-Hat / Snare Rhythm (Noise)
        musicState.tracks.drums.pattern = {
            1, 0, 1, 0, 1, 0, 1, 1,
            1, 0, 1, 0, 1, 1, 1, 0
        }

        -- Heroic Melody (Square)
        musicState.tracks.melody.pattern = {
            440, 0, 440, 523, 0, 0, 440, 0,
            659, 0, 587, 523, 587, 0, 0, 0
        }

        musicState.isPlaying = true
        musicState.step = 1
        stepSequencer()
    end
end

-- ============================================================
-- 3. PUBLIC API
-- ============================================================

function SoundBank.playMusic(name)
    SoundBank.playMusicInternal(name)
end

function SoundBank.setTrackVolume(trackName, volume)
    if musicState.tracks[trackName] then
        musicState.tracks[trackName].volume = volume
    end
end

function SoundBank.stopMusic()
    musicState.isPlaying = false
    if musicState.timer then
        musicState.timer:remove()
        musicState.timer = nil
    end
end

return SoundBank
