local Def = stitch "lua.geno".Def

local env = setmetatable({Def = Def},{__index = _G})
local function overlay(name)
    return stitch.RequireEnv("screens.overlay." .. name, env)
end

return Def.ActorFrame {
    overlay "music"
}