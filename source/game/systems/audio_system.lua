--[[
    AUDIO SYSTEM
    Manages sound effects and background music for entities with an audioSource.

    ── Playdate SDK Quick Reference ──────────────────────

    Sound effects (loaded into memory, for short sounds):
        local sfx = playdate.sound.sampleplayer.new("Sounds/jump")
        sfx:play()                         -- play once
        sfx:play(repeatCount)              -- repeat N times (0 = loop)
        sfx:stop()
        sfx:isPlaying()                    -- returns true/false
        sfx:setVolume(0.5)                 -- 0.0 to 1.0

    Background music (streamed from disk, for longer audio):
        local music = playdate.sound.fileplayer.new("Sounds/bgmusic")
        music:play()                       -- play once
        music:play(0)                      -- loop forever
        music:stop()
        music:pause()
        music:isPlaying()
        music:setVolume(0.5)

    File format: WAV or AIFF only (no MP3, no OGG)
    Path convention: use NO extension -- "Sounds/jump" not "Sounds/jump.wav"
    Place audio files in: source/Sounds/

    Synth (procedural audio, no files needed):
        local synth = playdate.sound.synth.new(waveform)
        -- Waveforms: kWaveSine, kWaveSquare, kWaveSawtooth,
        --            kWaveTriangle, kWaveNoise
        synth:playNote(freq, vol, duration)
        -- Example: synth:playNote(440, 0.5, 0.2)  -- A4 note, half volume, 0.2s

    Useful for quick prototyping without audio files:
        local beep = playdate.sound.synth.new(playdate.sound.kWaveSquare)
        beep:playNote(880, 0.3, 0.1)  -- short high beep

    Global volume:
        playdate.sound.setOutputsActive(leftEnabled, rightEnabled)

    ──────────────────────────────────────────────────────
]]

AudioSystem = System.new("audio", {"audioSource"}, function(entities, scene)
    for _, e in ipairs(entities) do
        local audio = e.audioSource

        -- Trigger-based playback: another system sets shouldPlay = true
        if audio.shouldPlay and audio.player then
            if not audio.player:isPlaying() then
                audio.player:play()
            end
            audio.shouldPlay = false
        end
    end

    -- TODO: Add background music management, volume control, etc.
    -- Tip: You can create a dedicated "music entity" with just an audioSource
    -- component and no transform, and manage background music through it.
end)
