return Def.ActorFrame {
    OnReady = function()
        local event = stitch "lua.event"
        local screen = stitch "lua.screen"
        event.Persist("key func", "escape", function(char)
            if char == "F5" then
                screen.SetNewScreen "Init"
            end
        end)

    end
}