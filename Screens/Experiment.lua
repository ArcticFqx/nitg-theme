local event = stitch "lua.event"

local function init(self)
    event.Add("input", "goback", function(k)
        if k == "Back" then 
            stitch "lua.screen" . SetNewScreen "TitleScreen"
        end
    end)
end

local wow = Def.ActorFrame {
    InitCommand=init,
    Def.Sprite {
        Name="White",
        File="/Graphics/white.png",
        InitCommand="align,0,0;zoomto,100,100;"
    },
    Def.Shader{
        Frag = [[
            #version 120

            void main (void)
            {
                gl_FragColor = vec4(1,0,0,1);
            }
        ]],
        InitCommand=function(shader)
            local as = stitch "lua.geno" . ActorByName
            as.White:SetShader(shader)
        end
    }
}

wow {
    Def.Sprite {
        File="/Graphics/note-48.png",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y
    }
}

return wow