--[[
    SOUND BANK (DYNAMIC MULTI-PATTERN)
    - Reactive Music Sequencer (Multi-track & Multi-phrase)
    - Polyphonic SFX Pool

    SFX: jump, coin, explosion, hit, coin2, dash, ding, powerup, hurt, pitch_up, pitch_down
    Music: theme, music1, music2
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
    elseif name == "coin2" then
        synth:setWaveform(snd.kWaveSquare)
        synth:setAttack(0.0)
        synth:setDecay(0.05)
        synth:setSustain(0.0)
        synth:setRelease(0.0)
        synth:playNote(523.25, 0.4, 0.03)
        pd.timer.performAfterDelay(30, function() synth:playNote(659.25, 0.4, 0.03) end)
        pd.timer.performAfterDelay(60, function() synth:playNote(783.99, 0.4, 0.1) end)
    elseif name == "dash" then
        synth:setWaveform(snd.kWaveNoise)
        synth:setAttack(0.01)
        synth:setDecay(0.1)
        synth:setSustain(0.0)
        synth:setRelease(0.05)
        synth:playNote(200, 0.6, 0.1)
    elseif name == "ding" then
        synth:setWaveform(snd.kWaveSine)
        synth:setAttack(0.01)
        synth:setDecay(0.4)
        synth:setSustain(0.0)
        synth:setRelease(0.2)
        synth:playNote(880, 0.3, 0.5)
    elseif name == "powerup" then
        synth:setWaveform(snd.kWaveSawtooth)
        synth:setAttack(0.05)
        synth:setDecay(0.2)
        synth:setSustain(0.2)
        synth:setRelease(0.1)
        synth:playNote(200, 0.5, 0.3)
    elseif name == "hurt" then
        synth:setWaveform(snd.kWaveSquare)
        synth:setAttack(0.0)
        synth:setDecay(0.2)
        synth:setSustain(0.0)
        synth:setRelease(0.1)
        synth:playNote(110, 0.7, 0.2)
    elseif name == "pitch_up" then
        synth:setWaveform(snd.kWaveSquare)
        -- Ajustamos el ADSR para que la nota no muera antes de tiempo
        synth:setAttack(0.01)
        synth:setDecay(0.3)
        synth:setSustain(0.5)
        synth:setRelease(0.1)
        -- playNote(frecuencia, volumen, duración, [frecuenciaFinal])
        -- Nota: En la versión 3.0+, el cuarto parámetro es duración y el quinto es frecuencia final
        synth:playNote(200, 0.5, 0.4, 800)
    elseif name == "pitch_down" then
        synth:setWaveform(snd.kWaveSawtooth)
        synth:setAttack(0.01)
        synth:setDecay(0.4)
        synth:setSustain(0.5)
        synth:setRelease(0.1)
        synth:playNote(800, 0.5, 0.4, 100)
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
    loop = true, -- Propiedad para controlar la repetición
    tracks = {
        bass = { synth = snd.synth.new(snd.kWaveTriangle), patterns = {}, volume = 0 },
        drums = { synth = snd.synth.new(snd.kWaveNoise), patterns = {}, volume = 0 },
        melody = { synth = snd.synth.new(snd.kWaveSquare), patterns = {}, volume = 0 },
    }
}

-- Init Master Volumes
musicState.tracks.bass.synth:setVolume(0.6)
musicState.tracks.drums.synth:setVolume(0.4)
musicState.tracks.melody.synth:setVolume(0.3)

local function stepSequencer()
    if not musicState.isPlaying then return end

    local step = musicState.step
    local pIdx = musicState.currentPatternIdx

    for name, track in pairs(musicState.tracks) do
        local currentPhrase = track.patterns[pIdx]
        if currentPhrase then
            local note = currentPhrase[step]
            if note and note > 0 and track.volume > 0 then
                if name == "drums" then
                    track.synth:setDecay(0.05)
                    track.synth:playNote(100, track.volume * 0.8, 0.05)
                else
                    track.synth:playNote(note, track.volume * 0.5, 0.15)
                end
            end
        end
    end

    -- Avance de paso
    musicState.step += 1

    if musicState.step > 16 then
        musicState.step = 1

        -- Verificamos si hay más patrones
        if pIdx < #musicState.tracks.bass.patterns then
            musicState.currentPatternIdx += 1
        else
            -- Fin de la lista de patrones
            if musicState.loop then
                musicState.currentPatternIdx = 1
            else
                SoundBank.stopMusic()
                return -- Salimos para no programar el siguiente timer
            end
        end
    end

    musicState.timer = pd.timer.performAfterDelay(musicState.tempo, stepSequencer)
end

function SoundBank.playMusicInternal(trackName)
    SoundBank.stopMusic()
    musicState.step = 1
    musicState.currentPatternIdx = 1
    musicState.loop = true -- Reset por defecto a true

    if trackName == "theme" then
        musicState.tempo = 150
        musicState.loop = true
        musicState.tracks.bass.patterns = { { 220, 0, 220, 0, 261, 0, 196, 0, 220, 0, 0, 0, 220, 0, 293, 196 } }
        musicState.tracks.drums.patterns = { { 1, 0, 1, 0, 1, 0, 1, 1, 1, 0, 1, 0, 1, 1, 1, 0 } }
        musicState.tracks.melody.patterns = { { 440, 0, 440, 523, 0, 0, 440, 0, 659, 0, 587, 523, 587, 0, 0, 0 } }
    elseif trackName == "win" then
        musicState.tempo = 150
        musicState.loop = false
        musicState.tracks.bass.patterns = { { 261, 329, 392, 523, 0, 523, 0, 523, 0, 0, 0, 0, 0, 0, 0, 0 } }
        musicState.tracks.drums.patterns = { { 1, 0, 1, 0, 1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0 } }
        musicState.tracks.melody.patterns = { { 523, 659, 783, 1046, 0, 1046, 0, 1046, 0, 0, 0, 0, 0, 0, 0, 0 } }
    elseif trackName == "lose" then
        musicState.tempo = 180
        musicState.loop = false
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
        musicState.tempo = 200
        musicState.loop = true
        musicState.tracks.bass.patterns = {
            { 0,   0, 0,   0, 0,   0, 0,   0, 0,   0, 0,   0, 0,   0, 0,   0 },
            { 130, 0, 196, 0, 174, 0, 247, 0, 130, 0, 196, 0, 174, 0, 164, 0 },
            { 130, 0, 196, 0, 174, 0, 247, 0, 130, 0, 196, 0, 174, 0, 164, 0 },
            { 130, 0, 146, 0, 164, 0, 174, 0, 196, 0, 220, 0, 247, 0, 123, 0 }
        }
        musicState.tracks.drums.patterns = {
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
            { 1, 0, 0, 1, 0, 0, 1, 0, 1, 0, 0, 1, 0, 0, 1, 1 },
            { 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 1, 1, 1, 1, 1 }
        }
        musicState.tracks.melody.patterns = {
            { 261, 329, 392, 493, 0,   0,   440, 0,   349, 440, 523, 659, 0,   0, 0, 0 },
            { 0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,   0, 0, 0 },
            { 261, 0,   329, 0,   392, 0,   493, 0,   440, 0,   349, 0,   293, 0, 0, 0 },
            { 523, 493, 440, 392, 349, 329, 293, 261, 261, 0,   0,   0,   0,   0, 0, 0 }
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
