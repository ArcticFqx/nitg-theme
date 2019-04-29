UI = {}

function UI:__index(k)
    return stitch ("ui." .. k)
end
setmetatable(UI, UI)

return UI