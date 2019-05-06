return Def.ActorFrame {
    OnCommand=function()
        PREFSMAN:SetPreference("DelayedScreenLoad",1)
        stitch "lua.screen" . SetNewScreen "TitleScreen"
    end
}