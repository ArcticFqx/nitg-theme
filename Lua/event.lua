local event = {}

local getn = table.getn
local unpack = unpack


local subs = {}
local persist = {}
local remove = {}
local stacksize = 0

function event.Reset()
    subs = {}
end

function event.Call(name, ...)
    stacksize = stacksize+1

    if persist[name] then
        for _, fn in pairs(persist[name]) do
            local r = {fn(unpack(arg))}
            if getn(r) > 0 then
                return unpack(r)
            end
        end
    end
    if subs[name] then
        for _, fn in pairs(subs[name]) do
            local r = {fn(unpack(arg))}
            if getn(r) > 0 then
                return unpack(r)
            end
        end
    end

    stacksize = stacksize-1
    if stacksize < 1 then
        for key,tab in pairs(remove) do
            for id in pairs(tab) do
                persist[key][id] = nil
                subs[key][id] = nil
            end
        end
    end
end

function event.Add(name, id, fn)
    subs[name] = subs[name] or {}
    subs[name][id] = fn
end

function event.Persist(name, id, fn)
    persist[name] = persist[name] or {}
    persist[name][id] = fn
end

local function nop() end
function event.Remove(name, id)
    if subs[name] then
        subs[name][id] = nop
    end
    if persist[name] then
        persist[name][id] = nop
    end
    remove[name] = remove[name] or {}
    remove[name][id] = true
end

local pt = os.clock()
function event:Update()
    local time = os.clock()
    local dt = time - pt
    pt = time
    event.Call("update", time, dt)
end

return event