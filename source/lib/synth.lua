audioController = nil
musicPlaying = false
musicTrackStates = {
    bass = false,
    drums = true,
    melody = false
}

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
    local newVol = musicTrackStates[trackName] and 1.0 or 0.0
    SynthDefaultTrackState()
end

function SynthStop()
    musicPlaying = false
end

function SynthPlay()
    musicPlaying = true
end

function SynthDestroy(scene)
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
    audioController.synthEmitter.trackVolumes[trackName] = state and 1.0 or 0.0
end

function SynthTriggerSFX(sfxName)
    audioController.synthEmitter.sfxTriggers = { sfxName }
end
