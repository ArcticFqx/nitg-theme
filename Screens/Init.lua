return Def.ActorFrame {
    OnCommand=function()
        PREFSMAN:SetPreference("DelayedScreenLoad", 1)
        MESSAGEMAN:Broadcast("RegisterOverlay")
        stitch "lua.screen" . SetNewScreen "TitleScreen"
    end,
    Name="Test"
}