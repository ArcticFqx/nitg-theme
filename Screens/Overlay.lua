local Def = stitch "lua.geno".Def

local function overlay(name)
    return stitch.RequireEnv("screens.overlay." .. name, {Def = Def})
end

return Def.ActorFrame {
    overlay "music",
    overlay "clock",
    overlay "escape",
    Def.ActorFrame { File="/Screens/Overlay/Console/" }
}