--[[
    SYSTEM
    A system processes entities that have specific components.
    Each system declares what components it requires, and only
    receives entities that have ALL of those components.

    Usage:
        MySystem = System.new("mySystem", {"transform", "velocity"}, function(entities, scene)
            for _, e in ipairs(entities) do
                e.transform.x += e.velocity.dx
            end
        end)

    The update function receives:
        entities  - list of entities matching this system's required components
        scene     - the current scene (for adding/removing entities, etc.)

    Inter-system communication:
        Systems talk to each other through components. For example, if the
        collision system detects a hit, it can set entity.audioSource.shouldPlay = true,
        and the audio system will pick it up on its next update.
]]

System = {}

function System.new(name, requiredComponents, updateFn)
    return {
        name = name,
        required = requiredComponents or {},
        update = updateFn or function() end,
        enabled = true,
    }
end

-- Returns only the entities that have ALL required components
function System.filter(system, entities)
    local result = {}
    for _, entity in ipairs(entities) do
        if entity.active then
            local match = true
            for _, comp in ipairs(system.required) do
                if entity[comp] == nil then
                    match = false
                    break
                end
            end
            if match then
                result[#result + 1] = entity
            end
        end
    end
    return result
end
