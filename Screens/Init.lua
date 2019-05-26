return Def.ActorFrame {
    InitCommand=function()
        MESSAGEMAN:Broadcast("RegisterOverlay")
        PREFSMAN:SetPreference("DelayedScreenLoad", 1)
    end,
    OnCommand=function()
        stitch "lua.overlay" . OnReady()
        stitch "lua.event" . Call "overlay ready"
        stitch "lua.screen" . SetNewScreen "TitleScreen"
    end
}