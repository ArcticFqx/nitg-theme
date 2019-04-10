local event = stx "lua.event"
local screen = stx "lua.screen"

local function init()
    event.Remove("input", screen)
    event.Add("input", screen, function(key, press)
        print(key)
        if key == "Up" and press then
            screen.SetNewScreen("Meow")
        end
    end)
end

return Def.ActorFrame{
    InitCommand = init,
    Def.Sprite {
        File="/Graphics/itg2.png",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y,
        InitCommand="zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;"
    }
}