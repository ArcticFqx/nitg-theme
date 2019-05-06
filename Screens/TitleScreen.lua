local event = stitch "lua.event"
local screen = stitch "lua.screen"
local UI = stitch "lua.ui"

local function audioInit(self)
    local names = stitch "lua.geno" . ActorByName

    local song
    local prev
    local prevSong = ""
    local curSong = ""

    local function formatName(song)
        return song:GetTranslitArtist () .. 
            "  -  " .. song:GetTranslitMainTitle ()
    end

    local function nextSong()
        prevSong = song and formatName(song) or ""
        song = SONGMAN:GetRandomSong()
        self:load(song:GetMusicPath())
        self:start()
        curSong = formatName(song)
        local bg = song:GetBackgroundPath()
        if bg then
            names.songbg:Load(bg)
            names.songbg:hidden(0)
            names.songbg:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
            names.songbg:align(0,0)
        else
            names.songbg:hidden(1)
        end
        print("Just played:", prevSong)
        print("Now playing:", curSong)
        prev = -1
    end

    local mod = 0
    event.Add("update", "song", function()
        mod = math.mod(mod,10) + 1
        local sp = self:get():GetSoundPosition()
        local beat = 1+math.mod(song:GetBeatFromElapsedTime(sp or 0)+0.11,1)/10
        local size = SCREEN_HEIGHT/2/SCREEN_HEIGHT*beat
        names.logo:zoom(size)
        names.progbar:zoomto(sp/song:MusicLengthSeconds()*SCREEN_WIDTH,2)
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
                names.songname:settext(string.sub(prevSong,0,string.len(prevSong)*(1-sp)))
            else
                sp = sp -1
                names.songname:settext(string.sub(curSong,0,string.len(curSong)*sp))
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

local function bmtInit(self)
    self:halign(0)
    self:valign(0)
    stitch "lua.keyboard" . Enable()

    event.Add("kb char", "readchar", function(c, spc)
        local text = self:GetText()
        if c == "\n" and spc.ctrl then
            self:settext("")
            assert(loadstring(text))()
        else
            self:settext(text .. c)
        end
    end)

    event.Add("kb special", "special", function(c)
        local text = self:GetText()
        if c == "backspace" then
            self:settext(string.sub(text, 1, string.len(text) -1 ))
        end
    end)
end

return Def.ActorFrame {
    Name="MainActorFrame",
    Def.Sprite{ -- rainbow background
        Name="BG",
        File="/Graphics/rainbow.jpg",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y,
        InitCommand="zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;diffuse,0.7,0.7,0.7,1"
    },
    Def.Sprite { -- song background
        File="/Graphics/rainbow.jpg",
        Name="songbg",
        InitCommand="diffuse,0.8,0.8,0.8,0.8"
    },
    Def.ActorFrame{
        Name="logo",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y/2,
        InitCommand="zoom,SCREEN_HEIGHT/2/SCREEN_HEIGHT",
        Def.Sprite{ -- nitg logo shadow
            File="/Graphics/nitglogo.png",
            X=3, Y=3,
            InitCommand="diffuse,0,0,0,0.5"
        },
        Def.Sprite{ -- nitg logo
            File="/Graphics/nitglogo.png",
        }
    },
    UI.Frame {
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y,
        OnCommand="zoom,0.5",
        Active=true,
        OnHover="linear,0.1;zoom,1.4",
        OnExit="linear,0.1;zoom,1",
        Padding=20,
        UI.Button {
            Text = "Start Game",
            File="/Fonts/_lato stroke 48px [main]",
            OnSelect = function (  )
                print("Hello world")
            end
        },
        UI.Button {
            Text = "Bye bye",
            File="/Fonts/_lato stroke 48px [main]",
            OnSelect = function (  )
                print("Second button")
            end
        },
        UI.Button {
            Text = "More options",
            File="/Fonts/_lato stroke 48px [main]",
            OnSelect = function (  )
                print("Third button")
            end
        }
    },--[[
    Def.BitmapText{ -- Lua scratch pad
        Name="button",
        File="/Fonts/_eurostile outline",
        Text="",
        X = 10, Y = SCREEN_CENTER_Y,
        InitCommand=bmtInit
    }, ]]
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
        File="/Music/dummy.wav",
        InitCommand=audioInit
    }
}