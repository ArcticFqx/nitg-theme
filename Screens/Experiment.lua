local event = stitch "lua.event"

local shader

local function init(self)
    event.Add("input", "goback", function(k)
        if k == "Back" then 
            stitch "lua.screen" . SetNewScreen "TitleScreen"
        end
    end)
end

return Def.ActorFrame {
    InitCommand=init,
    Def.Sprite {
        Name="White",
        File="/Graphics/white.png",
        InitCommand="diffuse,1,1,1,1;align,0,0;zoomto,100,100;"
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