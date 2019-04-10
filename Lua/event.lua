local event = {}

local getn = table.getn
local unpack = unpack


local subs = {}

event.Running = false

function event.Reset()
    event.Running = false
    subs = {}
end

function event.Call(name, ...)
    if not subs[name] then return end
    local subs = subs
    event.Running = true
    for _, fn in pairs(subs[name]) do
        if not event.Running then return end
        local r = {fn(unpack(arg))}
        if getn(r) > 0 then
            event.Running = false
            return unpack(r)
        end
    end
    event.Running = false
end

function event.Add(name, id, fn)
    subs[name] = subs[name] or {}
    subs[name][id] = fn
end

function event.Remove(name, id)
    if subs[name] then
        subs[name][id] = nil
    end
end

local pt = os.clock()
function event:Update()
    local time = os.clock()
    local dt = time - pt
    pt = time
    event.Call("update", time, dt)
end

return event