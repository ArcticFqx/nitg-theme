local event = stitch "lua.event"
local screen = stitch "lua.screen"
local UI = stitch "lua.ui"
local jukebox = stitch "lua.jukebox"

local function inrange(n, min, max)
    return math.min(math.max(n,min),max)
end

local function modulo(a, b)
    return a - math.floor(a / b) * b
end

local function titleInit()
    local actors = stitch "lua.geno" . ActorByName

    local fadebg = 1
    local nobg = string.format("/Themes/%s/Graphics/rainbow.jpg",THEME:GetCurThemeName())
    event.Add("jukebox next", "song", function()
        local bg = jukebox.GetSongBackground() or nobg
        fadebg = modulo(fadebg,2)+1
        if fadebg > 1 then
            actors.bgfade:Load(bg)
            actors.bgfade:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT)
            actors.bgfade:linear(0.6)
            actors.bgfade:diffusealpha(1)
        else
            actors.bgback:Load(bg)
            actors.bgback:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT)
            actors.bgfade:linear(0.6)
            actors.bgfade:diffusealpha(0)
        end
    end)

    event.Add("update", "song", function()
        local _, sb = jukebox.SongPositions(0.1)
        local beat = modulo(sb,1)
        local bs = 1+(beat^3)/10
        local bac = inrange(beat*2.25, 0, 1)
        local size = SCREEN_HEIGHT/2/SCREEN_HEIGHT

        actors.logo:zoom(size*bs)
        actors.logowave:zoom(size*(1+modulo(bac,1)/5))
        actors.logowave:diffuse(1,1,1,bac == 0 and 0 or 1-bac)
    end)
    
    local tex = actors.bgback:GetTexture()
    actors.bgback:Load(jukebox.GetSongBackground() or nobg)
    actors.bgback:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT)
end

return Def.ActorFrame {
    Name="MainActorFrame",
    InitCommand=titleInit,
    Def.Sprite{ -- rainbow background
        Name="bgback",
        File="/Graphics/rainbow.jpg",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y,
        InitCommand="diffuse,0.8,0.8,0.8,1"
    },
    Def.Sprite { -- song background
        Name="bgfade",
        File="/Graphics/rainbow.jpg",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y,
        InitCommand="diffuse,0.8,0.8,0.8,0"
    },
    Def.Sprite{ -- nitg logo waves
        File="/Graphics/notitg.png",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y/2+40,
        Name="logowave"
    },
    Def.ActorFrame{
        Name="logo",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y/2+40,
        InitCommand="zoom,SCREEN_HEIGHT/2/SCREEN_HEIGHT",
        Def.Sprite{ -- nitg logo shadow
            File="/Graphics/notitg.png",
            X=3, Y=3,
            InitCommand="diffuse,0,0,0,0.5"
        },
        Def.Sprite{ -- nitg logo
            File="/Graphics/notitg.png",
        }
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
                stitch "lua.screen" . SetNewScreen "SongSelect"
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