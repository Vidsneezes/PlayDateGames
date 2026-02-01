audioController = nil
musicPlaying = false
musicTrackStates = {
    bass = false,
    drums = true,
    melody = false
}
musicVolume = 0.35

function SynthStart(scene, trackName)
    -- Create our controller entity with the new SynthEmitter
    audioController = Entity.new({
        synthEmitter = SynthEmitter()
    })
    scene:addEntity(audioController)

    -- Start music immediately via ECS trigger
    audioController.synthEmitter.musicTrigger = trackName
    musicPlaying = true

    -- Melody starts muted (0.0)
    audioController.synthEmitter.trackVolumes = {
        bass = 0.0,
        drums = 0.0,
        melody = 0.0
    }

    SynthDefaultTrackState()
end

function SynthDefaultTrackState()
    SynthSetTrackState("bass", true)
    SynthSetTrackState("drums", true)
    SynthSetTrackState("melody", true)
end

function SynthSetMusic(trackName)
    musicTrackStates[trackName] = not musicTrackStates[trackName]
    local newVol = musicTrackStates[trackName] and musicVolume or 0.0
    SynthDefaultTrackState()
end

function SynthMute()
    SynthSetTrackState("bass", false)
    SynthSetTrackState("drums", false)
    SynthSetTrackState("melody", false)
end

function SynthStop()
    musicPlaying = false
    SoundBank.stopMusic()
end

function SynthPlay()
    musicPlaying = true
    SoundBank.playMusic()
end

function SynthDestroy(scene)
    SynthStop()

    if audioController then
        audioController.synthEmitter.musicTrigger = "stop"
    end

    scene:removeEntity(audioController)
    audioController = nil
end

function SynthUpdate(scene)
    local synthEntities = scene:getEntitiesWith("synthEmitter")
    SynthSystem.update(synthEntities, scene)
end

function SynthSetTrackState(trackName, state)
    audioController.synthEmitter.trackVolumes[trackName] = state and musicVolume or 0.0
end

function SynthTriggerSFX(sfxName)
    audioController.synthEmitter.sfxTriggers = { sfxName }
end
