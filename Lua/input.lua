local event = stx.Require "lua.event"

local input = {
    Map = { "Left", "Down", "Up", "Right", "Start", "Back", "dummy" },
    Any = {},
    Pad = {{},{}}
}

local Map = input.Map
local Any = input.Any
local Pad = input.Pad

for k, v in pairs(Map) do
    Any[k] = false
    Any[v] = false
    Pad[1][k] = false
    Pad[1][v] = false
    Pad[2][k] = false
    Pad[2][v] = false
end

function input.Subscribe(fn)
    event.Add("input", fn, fn)
end

--[[
local subs = {
    fn = {},
    us = {},
    ub = false,
    ii = false
}

-- Adds callback fn for inputs
-- fn(string key, bool press, number player)
function input.Subscribe(fn)
    if type(fn) == "function" then
        subs.fn[fn] = fn
    end
end

-- Unsubscribes the current executing function or
-- unsubscribes the passed function
-- Will not unsubscribe untill after callbacks has run
function input.Unsubscribe(fn)
    if fn then
        if not subs.ii then
            subs.fn[fn] = nil
        elseif subs.fn[fn] then
            subs.us[fn] = fn
        end
        return
    end
    subs.ub = subs.ii
end

local function RunCallbacks(key, press, ply)
    subs.ii = true
    for fn in pairs(subs.fn) do
        fn(key, press, ply)
        if subs.ub then
            subs.us[fn] = fn
            subs.ub = false
        end
    end
    subs.ii = false

    -- Cleanup for Unsubscribe
    if table.getn(subs.us) > 0 then
        for fn in pairs(subs.us) do
            subs.fn[fn] = nil
        end
        subs.us = {}
    end
end
]]

-- Function to trigger input
function input.Input(ply, key, press)
    return function()
        Pad[ply][key] = press
        Pad[Map[key]] = press
        Any[key] = Pad[1][key] or Pad[2][key]
        Any[Map[key]] = Any[key]

        event.Call("input", Map[key], press, ply)
        --RunCallbacks(Map[key], press, ply)
    end
end

return input