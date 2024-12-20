-- This migration turns all the old 1.1 py-valves into a configurable valve
-- with the correct circuit conditions

if not script.active_mods["pyindustry"] then return end

local util = require("util")

local replace_behaviour = {
    ["py-overflow-valve"]   = { name = "valves-overflow" },
    ["py-underflow-valve"]  = { name = "valves-top_up",     invert_direction = true },
    ["py-check-valve"]      = { name = "valves-one_way",    invert_direction = true },
}

for _, surface in pairs(game.surfaces) do
    for entity_name, config in pairs(replace_behaviour) do
        for _, entity in pairs(surface.find_entities_filtered{name = entity_name}) do
            local position = entity.position
            local direction = entity.direction
            local force = entity.force
            entity.destroy{raise_destroy = true}

            if config.invert_direction then
                direction = util.oppositedirection(direction)
            end

            local valve = surface.create_entity{
                name = config.name,
                position = position,
                force = force,
                direction = direction,
                raise_built = true,
            }
        end
    end
end