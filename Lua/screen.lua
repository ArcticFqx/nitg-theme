local event = stx "lua.event"

local screen = {}

local currentScreen = arg[1]
-- Swap vars, loads either LuaScreen or ScreenLua
local ls = "Lua"
local sl = "Screen"

function screen:Init( )
    print("Current screen is '" .. currentScreen .. "'")
    self:hidden(1)
end

function screen.SetNewScreen(name)
    currentScreen = name
    hasChanged = true
    sl,ls = ls,sl
    event.Call("screen new", name)
    event.Reset()
    print("About to load", name, "with", sl .. ls)
    SCREENMAN:SetNewScreen(sl .. ls)
end

function screen.GetLayout()
    local paths = {
        "screens." .. currentScreen,
        "screens." .. currentScreen .. ".default",
        "screens." .. currentScreen .. "." .. currentScreen
    }
    local Def = {Def = stx("lua.geno").Def}
    for k,v in pairs(paths) do
        local t = stx.RequireEnv(v, Def)
        if t then
            return t
        end
    end

    return {}
end

function screen:Overlay()
    stitch("lua.keyboard").Register(self)
end

return screen