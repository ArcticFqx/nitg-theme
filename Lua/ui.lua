local event = stitch "lua.event"

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

function UI.Enable()

    event.Add("input","ui", function(key, press, ply)
        local top = stack:Top()
        if not top then return end

    end)

    event.Add("screen new", "ui", function (  )
        repeat until not stack:Pop()
    end)
end

function UI.ActiveFrame(frame)
    -- Only one active frame
    if stack:Top() then return end
    
    stack:Push(frame)
end

local function build( t )
    
end

function UI:__index(k)
    return function ( t )
        t = stitch ("ui." .. k)( t )
        
        if t.Active then
            UI.ActiveFrame = t
        end
        
        return t
    end
end
setmetatable(UI, UI)

return UI