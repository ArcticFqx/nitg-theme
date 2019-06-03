return Def.ActorFrame {
    OnReady = function(overlay)
        local event = stitch "lua.event"
        local clock = overlay.Clock
        event.Persist("update","clock",function()
            clock:settext(os.date("%X"))
        end)
    end,
    Def.Text {
        Name="Clock",
        InitCommand="align,0,0;x,10;y,10;zoom,0.3;",
        Text=os.date("%X")
    }
}