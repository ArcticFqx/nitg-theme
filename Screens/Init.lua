return Def.ActorFrame {
    OnCommand=function()
        stitch "lua.screen" . SetNewScreen "TitleScreen"
    end
}