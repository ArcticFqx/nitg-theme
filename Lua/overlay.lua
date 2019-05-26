local actors = stitch "lua.geno" . Overlay
local template = stitch "screens.overlay"

local first = true

local overlay = {}

function overlay.OnReady()
    for i,v in ipairs(template) do
        if v.OnReady then
            v.OnReady(actors, first)
        end
    end
    first = false
end

return overlay