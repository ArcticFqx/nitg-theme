local event = stitch "lua.event"
local screen = stitch "lua.screen"
local UI = stitch "lua.ui"
local jukebox = stitch "lua.jukebox"

local nobg = string.format("/Themes/%s/Graphics/rainbow.jpg",THEME:GetCurThemeName())

local function clamp(n, min, max)
    return math.min(math.max(n,min),max)
end

local function modulo(a, b)
    return a - math.floor(a / b) * b
end

local function checkBG(actor)
    local tex = actor:GetTexture()
    local swh = tex:GetTextureWidth() + tex:GetTextureHeight()
    if swh < 32 then
        actor:Load(nobg)
    end
end

local function titleInit()
    local actors = stitch "lua.geno" . ActorByName

    local fadebg = 1
    event.Add("jukebox next", "song", function()
        local bg = jukebox.GetSongBackground() or nobg
        fadebg = modulo(fadebg,2)+1
        if fadebg > 1 then
            actors.bgfade:Load(bg)
            checkBG(actors.bgfade)
            actors.bgfade:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT)
            actors.bgfade:linear(0.6)
            actors.bgfade:diffusealpha(1)
        else
            actors.bgback:Load(bg)
            checkBG(actors.bgback)
            actors.bgback:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT)
            actors.bgfade:linear(0.6)
            actors.bgfade:diffusealpha(0)
        end
    end)
    
    local aft = actors.aft
    local oneFrame = 1/60
    local lastClock = os.clock()+oneFrame
    local hidden = true
    event.Add("update", "song", function(t)
        local _, sb = jukebox.SongPositions(0.1)
        local beat = modulo(sb,1)
        local bs = 1+(beat^3)/10
        local bac = clamp(beat*2.25, 0, 1)
        local size = SCREEN_HEIGHT/2/SCREEN_HEIGHT

        actors.logoaft:zoom(size*bs)
        actors.logotop:zoom(size*bs)
        actors.logowave:zoom(size*(1+modulo(bac,1)/5))
        actors.logowave:diffuse(1,1,1,bac == 0 and 0 or 1-bac)
        
        if t >= lastClock and hidden then
            lastClock = t+oneFrame
            hidden = false
            aft:hidden(0)
        elseif not hidden then
            hidden = true
            aft:hidden(1)
        end
    end)
    
    actors.bgback:Load(jukebox.GetSongBackground() or nobg)
    checkBG(actors.bgback)
    actors.bgback:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT)

    aft:SetWidth(DISPLAY:GetDisplayWidth())
    aft:SetHeight(DISPLAY:GetDisplayHeight())
    aft:EnablePreserveTexture(true)
    aft:Create()

    actors.aftspriteback:diffusealpha(0.9)
    actors.aftspriteback:SetTexture(aft:GetTexture())
    actors.aftspritefront:SetTexture(aft:GetTexture())
end

return Def.ActorFrame {
    Name="MainActorFrame",
    InitCommand=titleInit,
    Def.Sprite {
        File="/Graphics/white.png",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y,
        InitCommand="zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;diffuse, 0,0,0,1"
    },
    Def.Sprite { -- nitg logo
        Name="logowave",
        File="/Graphics/notitg.png",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y/2+40
    },
    Def.Sprite{
        Name="logoaft",
        File="/Graphics/notitg.png",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y/2+40
    },
    Def.Sprite {
        Name="aftspriteback",
        File="/Graphics/white.png",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y+2.3,
        InitCommand=[[  basezoomx,SCREEN_WIDTH/DISPLAY:GetDisplayWidth();
                        basezoomy,-1*(SCREEN_HEIGHT/DISPLAY:GetDisplayHeight());
                        zoom,1.025;]]
    },
    Def.ActorFrameTexture { Name="aft" },
    Def.Sprite{ -- rainbow background
        Name="bgback",
        File="/Graphics/rainbow.jpg",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y,
        InitCommand="diffuse,0.5,0.5,0.5,1"
    },
    Def.Sprite { -- song background
        Name="bgfade",
        File="/Graphics/rainbow.jpg",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y,
        InitCommand="diffuse,0.5,0.5,0.5,0"
    },
    Def.Sprite { 
        Name="aftspritefront", 
        File="/Graphics/white.png",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y,
        InitCommand=[[  basezoomx,SCREEN_WIDTH/DISPLAY:GetDisplayWidth();
                        basezoomy,-1*(SCREEN_HEIGHT/DISPLAY:GetDisplayHeight());
                        zoom,1;]]
    },
    Def.Shader {
        Frag = [[
            #version 120
            uniform sampler2D sampler0;
            varying vec2 textureCoord;
            varying vec4 color;

            void main (void)
            {
                vec4 t = texture2D( sampler0, textureCoord );
                t.a = sqrt(pow(0.299*t.r,2)+pow(0.587*t.g,2)+pow(0.114*t.b,2))*2;
                gl_FragColor = t*color;
            }
        ]],
        InitCommand = function(self)
            local as = stitch"lua.geno".ActorByName
            as.aftspritefront:SetShader(self)
        end
    },
    Def.Sprite { -- nitg logo
        Name="logotop",
        File="/Graphics/notitg.png",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y/2+40
    },
    UI.Frame {
        X=SCREEN_CENTER_X, Y=SCREEN_HEIGHT*3/5+50,
        OnCommand="zoom,0.5",
        Active=true,
        OnHover="linear,0.1;zoom,1.4",
        OnExit="linear,0.1;zoom,1",
        Padding=26,
        Font="/Fonts/_lato stroke 48px [main]",
        UI.Button {
            Text = "Start Game",
            OnSelect = function (  )
                stitch "lua.screen" . SetNewScreen "Experiment"
            end
        },
        UI.Button {
            Text = "Lua Sandbox",
            OnSelect = function (  )
                stitch "lua.screen" . SetNewScreen "Sandbox"
            end
        },
        UI.Button {
            Text = "More options",
            OnSelect = function (  )
                print("Third button")
            end
        }
    }
}