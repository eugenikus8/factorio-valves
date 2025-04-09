local constants = require("__valves__.constants")

local shortcuts = { }

---@param input "minus" | "plus"
---@param event EventData.CustomInputEvent
local function quick_toggle(input, event)
    local player = game.get_player(event.player_index)
    if not player then return end
    local valve = player.selected
    if not valve then return end
    if not constants.valve_names[valve.name] and not (
        valve.name == "entity-ghost" and constants.valve_names[valve.ghost_name]
    ) then return end

    local valve_type = constants.valve_names[valve.name]
    if valve_type == "one_way" then
        player.create_local_flying_text{text = {"valves.configuration-doesnt-support-thresholds"}, create_at_cursor=true}
        return
    end

    local threshold = valve.valve_threshold_override or constants.default_thresholds[valve_type]
    threshold = (math.floor(threshold/0.1)*0.1) + (0.1 * (input == "plus" and 1 or -1 ))
    threshold = math.min(1, math.max(0, threshold))
    valve.valve_threshold_override = threshold

    -- Visualize it to the player
    valve.create_build_effect_smoke()
    storage.players = storage.players or {}
    local player_data = storage.players[event.player_index]
    if not player_data then return end
    if player_data.render_threshold then
        player_data.render_threshold.text = tostring(threshold) -- TODO: This also needs rounding.
    end
end

shortcuts.events = { }
for input, custom_input in pairs({
    minus = "valves-threshold-minus",
    plus = "valves-threshold-plus",
}) do
    shortcuts.events[custom_input] = function(e) quick_toggle(input, e) end
end


return shortcuts