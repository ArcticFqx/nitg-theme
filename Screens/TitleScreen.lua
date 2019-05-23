local event = stitch "lua.event"
local screen = stitch "lua.screen"
local UI = stitch "lua.ui"

local function inrange(n, min, max)
    return math.min(math.max(n,min),max)
end

local function modulo(a, b)
    return a - math.floor(a / b) * b
end

local function audioInit(self)
    local actors = stitch "lua.geno" . ActorByName

    local song
    local prev
    local prevSong = ""
    local curSong = ""

    local function formatName(song)
        return string.format("%s  -  %s",
            song:GetTranslitArtist(),
            song:GetTranslitMainTitle()
        )
    end

    local fadebg = 1
    local function nextSong()
        prevSong = song and formatName(song) or ""
        song = SONGMAN:GetRandomSong()
        self:load(song:GetMusicPath())
        self:start()
        curSong = formatName(song)
        local bg = song:GetBackgroundPath() or 
                string.format("/Themes/%s/Graphics/rainbow.jpg",THEME:GetCurThemeName())

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
        fadebg = modulo(fadebg,2)+1

        print("Just played:", prevSong)
        print("Now playing:", curSong)
        prev = -1
    end

    local mod = 0
    event.Add("update", "song", function()
        mod = modulo(mod,10) + 1
        local sp = self:get():GetSoundPosition()
        --print(sp, song:GetBeatFromElapsedTime(sp))
        local bt = song:GetBeatFromElapsedTime(sp or 0)+0.11
        local beat = modulo(bt,1)
        local bs = 1+(beat^3)/10
        local bac = inrange(beat*2.25, 0, 1)
        local size = SCREEN_HEIGHT/2/SCREEN_HEIGHT

        actors.logo:zoom(size*bs)
        actors.logowave:zoom(size*(1+modulo(bac,1)/5))
        actors.logowave:diffuse(1,1,1,bac == 0 and 0 or 1-bac)
        actors.progbar:zoomto(sp/song:MusicLengthSeconds()*SCREEN_WIDTH,2)

        if mod == 1 then -- rate limiting
            if sp == prev and sp ~= 0 then
                nextSong()
            else
                prev = sp
            end
        end
        sp = sp*3
        if sp < 2.1 then
            if sp < 1 then
                actors.songname:settext(string.sub(prevSong,0,string.len(prevSong)*(1-sp)))
            else
                sp = sp -1
                actors.songname:settext(string.sub(curSong,0,string.len(curSong)*sp))
            end
        end
    end)

    event.Add("input", "nextsong", function(c, p)
        if c == "Right" and p then
            --nextSong()
        end
    end)

    nextSong()
end

return Def.ActorFrame {
    Name="MainActorFrame",
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
        X=SCREEN_CENTER_X, Y=SCREEN_HEIGHT*3/5+30,
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
    },
    Def.Quad { -- Song name field
        X=SCREEN_CENTER_X, Y=SCREEN_HEIGHT,
        InitCommand="valign,1;zoomto,SCREEN_WIDTH,24;diffuse,0,0,0,0.5"
    },
    Def.Quad { -- Prog bar shading
        Y=SCREEN_HEIGHT - 22,
        InitCommand="align,0,1;diffuse,0,0,0,0.7;zoomto,SCREEN_WIDTH,2"
    },
    Def.Quad { -- Prog bar
        Name="progbar",
        Y=SCREEN_HEIGHT - 22,
        InitCommand="align,0,1;diffuse,0,1,1,0.5;zoomto,0,2"
    },
    Def.BitmapText{ -- Song name
        Name="songname",
        File="/Fonts/_lato stroke 48px [main]",
        Text="!",
        X = 26, Y = SCREEN_HEIGHT-6,
        InitCommand="align,0,1;zoom,0.3"
    },
    Def.ActorFrame {
        X=4, Y=SCREEN_HEIGHT-4,
        InitCommand="zoom,0.3",
        Def.Sprite { -- Note icon shadow
            File="/Graphics/note-48.png",
            X = 4/0.3, Y = 4/0.3,
            InitCommand="align,0,1;diffuse,0,0,0,0.5"
        },
        Def.Sprite { -- Note icon
            File="/Graphics/note-48.png",
            InitCommand="align,0,1"
        },
    },
    Def.Audio { -- Music
        File="/Sounds/dummy.wav",
        InitCommand=audioInit
    }
}