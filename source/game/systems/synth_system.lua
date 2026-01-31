--[[
    SYNTH SYSTEM
    Processes SynthEmitter components and triggers sounds via SoundBank.
    This separates game logic (requests) from audio logic (synthesis).
]]

import "lib/sound_bank"

SynthSystem = System.new("synth", { "synthEmitter" }, function(entities, scene)
    for _, e in ipairs(entities) do
        local emitter = e.synthEmitter

        -- 1. Process SFX Triggers
        if #emitter.sfxTriggers > 0 then
            for _, sfxName in ipairs(emitter.sfxTriggers) do
                SoundBank.playSfx(sfxName)
            end
            -- Clear triggers immediately after processing
            emitter.sfxTriggers = {}
        end

        -- 2. Process Music Trigger (State change)
        if emitter.musicTrigger then
            if emitter.musicTrigger == "stop" then
                SoundBank.stopMusic()
            else
                SoundBank.playMusic(emitter.musicTrigger)
            end
            -- Clear trigger
            emitter.musicTrigger = nil
        end

        -- 3. Process Track Volume Changes (Reactive Music)
        -- We loop through keys because user might set {melody=1.0} or {drums=0.0}
        for trackName, vol in pairs(emitter.trackVolumes) do
            SoundBank.setTrackVolume(trackName, vol)
        end
        -- Clear volume requests (so we don't spam the function calls)
        emitter.trackVolumes = {}
    end
end)
