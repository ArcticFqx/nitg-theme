local jukebox = stitch "lua.jukebox"

local function modulo(a, b)
    return a - math.floor(a / b) * b
end

local function formatName(song)
    return string.format("%s  -  %s",
        jukebox.CurrentSong())
end

local function update(sound, name, bar)
    local sl = jukebox.SongLength()
    local sp = jukebox.SongPositions()

    bar:zoomto(sp/sl*SCREEN_WIDTH,2) 
end

local function ready(actors)
    local event = stitch "lua.event"
    local sound = actors.Music
    local name = actors.MusicName
    local bar = actors.MusicBar
    
    event.Persist("jukebox next", "screen.music.next", function()
        name:settext(formatName())
    end)

    event.Persist("overlay update", "screen.music.update", function()
        update(sound, name, bar)
    end)
    
    jukebox.NextSong()
    jukebox.AutoNext()
end

return Def.ActorFrame {
    OnReady = ready,
    Def.Audio {
        Name="Music",
        File="/Sounds/silent.wav"
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
        Name="MusicBar",
        Y=SCREEN_HEIGHT - 22,
        InitCommand="align,0,1;diffuse,0,1,1,0.5;zoomto,0,2"
    },
    Def.Text { -- Song name
        Name="MusicName",
        File="/Fonts/_lato stroke 48px [main]",
        Text=formatName(),
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
        }
    }
}
