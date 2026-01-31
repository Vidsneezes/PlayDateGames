--[[
    AUDIO COMPONENTS
    Components related to sound effects and music.
    Add new audio-related components at the bottom of this file.

    Usage:
        local sfx = playdate.sound.sampleplayer.new("Sounds/jump")
        local entity = Entity.new({
            audioSource = AudioSource(sfx),
        })

    To trigger playback from another system, set:
        entity.audioSource.shouldPlay = true
    The AudioSystem will play it and reset the flag.
]]

-- Sound attached to an entity (used by AudioSystem)
function AudioSource(player)
    return {
        player = player,    -- a sampleplayer or fileplayer instance
        shouldPlay = false, -- set to true to trigger playback
    }
end

-- Component for purely synthesized audio (no files)
-- Used by SynthSystem + SoundBank
function SynthEmitter()
    return {
        sfxTriggers = {},   -- List of SFX names to play this frame: { "jump", "coin" }
        musicTrigger = nil, -- Music command to set this frame: "theme" or "stop"
    }
end
