--[[
    SOUND BANK (DYNAMIC MULTI-PATTERN)
    - Reactive Music Sequencer (Multi-track & Multi-phrase)
    - Polyphonic SFX Pool

    USAGE IN SCENES:

    1. Play music (in scene:onEnter):
        SoundBank.playMusic("menu")  -- or "win", "lose", etc.
        SoundBank.setTrackVolume("bass", 0.8)
        SoundBank.setTrackVolume("melody", 0.7)
        SoundBank.setTrackVolume("drums", 0.6)

    2. Stop music (in scene:onExit):
        SoundBank.stopMusic()

    3. Play sound effects (anywhere, anytime - no setup needed):
        SoundBank.playSfx("explosion")  -- "jump", "coin", "hit", "explosion"

    NOTE: No initialization required! SoundBank is always ready.
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

for i = 1, SFX_VOICES do
    table.insert(sfxPool, snd.synth.new(snd.kWaveSquare))
end

function SoundBank.playSfx(name)
    local synth = sfxPool[sfxIndex]
    sfxIndex = (sfxIndex % SFX_VOICES) + 1

    if synth:isPlaying() then synth:stop() end

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
-- 2. MUSIC SEQUENCER (Multi-Pattern)
-- ============================================================
local musicState = {
    isPlaying = false,
    timer = nil,
    step = 1,
    currentPatternIdx = 1,
    tempo = 150,
    tracks = {
        bass = { synth = snd.synth.new(snd.kWaveTriangle), patterns = {}, volume = 0 },
        drums = { synth = snd.synth.new(snd.kWaveNoise), patterns = {}, volume = 0 },
        melody = { synth = snd.synth.new(snd.kWaveSquare), patterns = {}, volume = 0 },
    }
}

-- Init Master Volumes
musicState.tracks.bass.synth:setVolume(0.9)
musicState.tracks.drums.synth:setVolume(0.6)
musicState.tracks.melody.synth:setVolume(0.5)

local function stepSequencer()
    if not musicState.isPlaying then return end

    local step = musicState.step
    local pIdx = musicState.currentPatternIdx

    for name, track in pairs(musicState.tracks) do
        -- Obtenemos la frase actual (si no existe, usamos la primera por seguridad)
        local currentPhrase = track.patterns[pIdx] or track.patterns[1]
        local note = currentPhrase and currentPhrase[step]

        if note and note > 0 and track.volume > 0 then
            if name == "drums" then
                track.synth:setDecay(0.05)
                track.synth:playNote(100, track.volume * 0.8, 0.05)
            else
                track.synth:playNote(note, track.volume * 0.5, 0.15)
            end
        end
    end

    -- Lógica de progresión
    musicState.step += 1
    if musicState.step > 16 then
        musicState.step = 1
        -- Avanzar al siguiente patrón disponible en el track de bajo (referencia)
        local totalPatterns = #musicState.tracks.bass.patterns
        musicState.currentPatternIdx = (pIdx % totalPatterns) + 1
    end

    musicState.timer = pd.timer.performAfterDelay(musicState.tempo, stepSequencer)
end

function SoundBank.playMusicInternal(trackName)
    SoundBank.stopMusic()
    musicState.step = 1
    musicState.currentPatternIdx = 1

    if trackName == "theme" then
        musicState.tempo = 150
        musicState.tracks.bass.patterns = { { 220, 0, 220, 0, 261, 0, 196, 0, 220, 0, 0, 0, 220, 0, 293, 196 } }
        musicState.tracks.drums.patterns = { { 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0 } }
        musicState.tracks.melody.patterns = { { 440, 0, 440, 523, 0, 0, 440, 0, 659, 0, 587, 523, 587, 0, 0, 0 } }
    elseif trackName == "win" then
        musicState.tempo = 150
        musicState.tracks.bass.patterns = { { 261, 329, 392, 523, 0, 523, 0, 523, 0, 0, 0, 0, 0, 0, 0, 0 } }
        musicState.tracks.drums.patterns = { { 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 } }
        musicState.tracks.melody.patterns = { { 523, 659, 783, 1046, 0, 1046, 0, 1046, 0, 0, 0, 0, 0, 0, 0, 0 } }
    elseif trackName == "lose" then
        musicState.tempo = 180 -- Más lento para tristeza
        musicState.tracks.bass.patterns = { { 196, 185, 174, 164, 147, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } }
        musicState.tracks.drums.patterns = { { 1, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } }
        musicState.tracks.melody.patterns = { { 392, 370, 349, 329, 293, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } }
    elseif trackName == "music1" then
        musicState.tempo = 140
        musicState.currentPatternIdx = 1

        -- BASS: Walking Bassline (Saltarina)
        musicState.tracks.bass.patterns = {
            -- Frase A: Estabilidad
            { 130, 0, 164, 0, 196, 0, 164, 0, 130, 0, 164, 0, 196, 0, 164, 0 },
            { 130, 0, 164, 0, 196, 0, 164, 0, 130, 0, 164, 0, 196, 0, 164, 0 },
            -- Frase B: Subida al IV grado
            { 174, 0, 220, 0, 261, 0, 220, 0, 174, 0, 220, 0, 261, 0, 220, 0 },
            { 130, 0, 164, 0, 196, 0, 164, 0, 196, 0, 185, 0, 174, 0, 146, 0 }
        }

        -- DRUMS: Swing/Shuffle típico de GameBoy
        musicState.tracks.drums.patterns = {
            { 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 0, 1, 1, 1, 1, 0 },
            { 1, 0, 0, 1, 1, 0, 0, 1, 1, 0, 1, 0, 1, 0, 1, 0 }
        }

        -- MELODY: Sincopada y juguetona
        musicState.tracks.melody.patterns = {
            { 261, 0,   329, 392, 0, 523, 0,   392, 0,   329, 0, 261, 0, 0, 0, 0 }, -- C, E, G, C
            { 261, 0,   329, 392, 0, 523, 0,   659, 0,   587, 0, 523, 0, 0, 0, 0 }, -- C, E, G, C, E, D, C
            { 349, 0,   440, 523, 0, 698, 0,   523, 0,   440, 0, 349, 0, 0, 0, 0 }, -- F, A, C, F
            { 392, 440, 493, 523, 0, 0,   523, 0,   523, 0,   0, 0,   0, 0, 0, 0 }  -- G, A, B, C
        }
    elseif trackName == "music2" then
        musicState.tempo = 100 -- Más rápido
        musicState.currentPatternIdx = 1

        -- BASS: Tenso y descendente
        musicState.tracks.bass.patterns = {
            { 130, 0,   130, 0,   123, 0,   123, 0,   116, 0,   116, 0,   110, 0, 110, 0 }, -- C, B, Bb, A
            { 130, 130, 130, 130, 123, 123, 123, 123, 116, 116, 116, 116, 110, 0, 0,   0 }
        }

        -- DRUMS: Doble tiempo (Agresivo)
        musicState.tracks.drums.patterns = {
            { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
            { 1, 0, 1, 0, 1, 1, 1, 1, 1, 0, 1, 0, 1, 1, 1, 1 }
        }

        -- MELODY: Tritonos y saltos histéricos
        musicState.tracks.melody.patterns = {
            { 261,  311, 261, 311, 261,  311, 261, 311, 370,  0,   370, 0,   370,  0,    370,  0 },   -- C - Eb (Menor) + F# (Disonancia)
            { 523,  0,   493, 0,   466,  0,   440, 0,   415,  0,   392, 0,   370,  0,    349,  0 },   -- Escala cromática descendente
            { 261,  311, 261, 311, 261,  311, 261, 311, 370,  370, 440, 440, 523,  523,  622,  622 },
            { 1046, 0,   0,   0,   1046, 0,   0,   0,   1046, 0,   0,   0,   1046, 1046, 1046, 1046 } -- Pánico total
        }
    elseif trackName == "menu" then
        musicState.tempo = 200 -- Más lento (Jazz/Casual)
        musicState.currentPatternIdx = 1

        -- BASS: Smooth Jazz Walking (Aterciopelado)
        musicState.tracks.bass.patterns = {
            { 0,   0, 0,   0, 0,   0, 0,   0, 0,   0, 0,   0, 0,   0, 0,   0 }, -- Bloque 1: Silencio (Solo Prelude)
            { 130, 0, 196, 0, 174, 0, 247, 0, 130, 0, 196, 0, 174, 0, 164, 0 }, -- Bloque 2: Entra Bajo (C-G-F-B)
            { 130, 0, 196, 0, 174, 0, 247, 0, 130, 0, 196, 0, 174, 0, 164, 0 }, -- Bloque 3: Con Percusión
            { 130, 0, 146, 0, 164, 0, 174, 0, 196, 0, 220, 0, 247, 0, 123, 0 } -- Bloque 4: Variación para Loop
        }

        -- DRUMS: Bossa-Style Soft Clicks
        musicState.tracks.drums.patterns = {
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, -- Bloque 1
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }, -- Bloque 2
            { 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1 }, -- Bloque 3: Síncopa Jazz
            { 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1 } -- Bloque 4: Cierre suave
        }

        -- MELODY: Acordes Jazz (Usando terceras y séptimas)
        musicState.tracks.melody.patterns = {
            { 261, 329, 392, 493, 0,   0,   440, 0,   349, 440, 523, 659, 0,   0, 0, 0 }, -- Bloque 1: Prelude (Maj7 chords)
            { 0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 0, 0 }, -- Bloque 2: Solo Bajo
            { 261, 0,   329, 0,   392, 0,   493, 0,   440, 0,   349, 0,   293, 0, 0, 0 }, -- Bloque 3: Melodía Bossa
            { 523, 493, 440, 392, 349, 329, 293, 261, 261, 0,   0,   0,   0,   0, 0, 0 } -- Bloque 4: Descenso suave
        }
    end

    musicState.isPlaying = true
    stepSequencer()
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
