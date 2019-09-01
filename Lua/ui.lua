local event = stitch "lua.event"

local getn = table.getn

local stack = {}
function stack:Push(entry)
    self[getn(self) + 1] = entry
end

function stack:Pop()
    local t = self[getn(self)]
    self[getn(self)] = nil
    return t
end

function stack:Top()
    return self[getn(self)]
end

local UI = {}
event.Add("input","ui", function(key, press, ply)
    local top = stack:Top()
    if not top then return end
end)

event.Persist("screen new", "ui", function ( )
    repeat until not stack:Pop()
end)

function UI.PushFrame(frame)
    stack:Push(frame)
end


function UI:__index(k)
    return function ( t )
        t = stitch ("ui." .. k)( t )
        
        if t.Active then
            UI.PushFrame( t )
        end
        
        return t
    end
end
setmetatable(UI, UI)

return UI