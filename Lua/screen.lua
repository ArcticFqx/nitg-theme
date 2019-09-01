local event = stitch "lua.event"

local screen = {
    ExitPath = "echo", -- should be read only
    ExitParam = "done" -- should be read only
}

local reserved = {
    Prepare = true,
    PlayGame = true,
    ScreenGamePlay = true
}

local currentScreen = arg[1]
local ls = "Lua"
local sl = "Screen"
local check = false
function screen:Init( )
    print("Setting new Lua screen '" .. currentScreen .. "'")
    self:hidden(1)
end

function screen.Next()
    sl,ls = ls,sl
    return sl .. ls
end

function screen.Prepare(name)
    currentScreen = name
    event.Call("screen new", name)
    event.Reset()
    return name
end

function screen.SetNewScreen(name)
    screen.Prepare(name)
    if reserved[name] then
        SCREENMAN:SetNewScreen(name)
    else
        SCREENMAN:SetNewScreen(screen.Next())
    end
end

function screen.Exit(path)
    if reserved[currentScreen] then return end
    if path then
        screen.ExitPath = "cmd"
        screen.ExitParam = "/c start " .. path
    end
    SCREENMAN:SetNewScreen("ExitGame")
end

function screen.GetLayout()
    local paths = {
        "screens." .. currentScreen,
        "screens." .. currentScreen .. ".default",
        "screens." .. currentScreen .. "." .. currentScreen
    }
    local Def = {Def = stitch("lua.geno").Def}
    for k,v in pairs(paths) do
        local t = stitch.nocache(v, Def)
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