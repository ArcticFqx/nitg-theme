return Def.ActorFrame {
    OnReady = function()
        local event = stitch "lua.event"
        local screen = stitch "lua.screen"
        event.Persist("kb char", "escape", function(char)
            if char == "F5" then
                screen.SetNewScreen "TitleScreen"
            end
        end)

    end
}