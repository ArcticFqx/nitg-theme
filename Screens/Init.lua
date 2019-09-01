return Def.ActorFrame {
    InitCommand=function()
        MESSAGEMAN:Broadcast("RegisterOverlay")
        PREFSMAN:SetPreference("DelayedScreenLoad", 1)
    end,
    OnCommand=function()
        stitch "lua.overlay" . OnReady()
        stitch "lua.event" . Call "overlay ready"
        MESSAGEMAN:Broadcast("OverlayReady")
        ModCustom = { LifeBar = {1,1}, JudgmentFont = {1,1}, Compare = {1,1}, Measure = {1,1} }
        stitch "lua.screen" . SetNewScreen "TitleScreen"
    end
}