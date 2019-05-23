return Def.ActorFrame {
    OnCommand=function()
        MESSAGEMAN:Broadcast("RegisterOverlay")
        PREFSMAN:SetPreference("DelayedScreenLoad", 1)
        stitch "lua.screen" . SetNewScreen "TitleScreen"
    end
}