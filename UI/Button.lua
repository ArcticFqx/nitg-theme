local UI = stitch "lua.ui"
local Def = stitch "lua.geno" . Def

local function construct ( t )
    local af = Def.BitmapText( t )
    af.UI = "Button"
    return af
end

return construct
