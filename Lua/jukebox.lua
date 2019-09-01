local event = stitch "lua.event"
local sound = stitch "lua.geno" .Overlay.Music

local jukebox = {}

local song, prev
local isPlaying = false
local isAutoplay = false
local isGameplay = false

function jukebox.NextSong(newSong, game)
    print("Just played:", jukebox.CurrentSong())
    prev = song
    song = newSong or SONGMAN:GetRandomSong()
    print("Now playing:", jukebox.CurrentSong())
    isGameplay = game

    if not isGameplay then
        sound:load(song:GetMusicPath())
        sound:start()
    end

    isPlaying = true
    event.Call("jukebox next")
end

function jukebox.AutoNext(bool)
    if bool ~= nil then
        isAutoplay = bool
    else
        isAutoplay = true
    end
end

function jukebox.CurrentSong()
    if song then 
        return song:GetTranslitArtist(), 
            song:GetTranslitMainTitle()
    else
        return "No artist", "Nothing's playing"
    end
end

function jukebox.SongLength()
    if song then
        return song:MusicLengthSeconds()
    else
        return -1
    end
end

function jukebox.SongPositions(offset)
    if isGameplay then
        return GAMESTATE:GetSongTime()
    else
        local pos = sound:get():GetSoundPosition() + (offset or 0)
        return pos, song and song:GetBeatFromElapsedTime(pos) or 0
    end
end

function jukebox.IsPlaying()
    return isPlaying
end

function jukebox.Pause()
    sound:stop()
    isPlaying = false
end

function jukebox.Find(s)
    local search = stitch "lua.songsearch"
    local r = search.Find(s)

    local o = {}
    for _,v in pairs(r) do
        local up = v
        o[table.getn(o)+1] = setmetatable({
            Artist = v:GetTranslitArtist (),
            Title = v:GetTranslitMainTitle (),
            Length = SecondsToMMSS (v:MusicLengthSeconds ()),
            Subtitle = string.sub(v:GetTranslitFullTitle(), string.len(v:GetTranslitMainTitle())+2),
            Song = v
        },{
            __call = function(self)
                jukebox.NextSong(self.Song)
            end
        })
    end
    return o
end

function jukebox.Stop()
    jukebox.Pause()
    song = nil
    event.Call("jukebox next")
end

local vid = {
    avi = true, mpg = true, mpeg = true, mp4 = true, webm = true, mkv = true
}
function jukebox.GetSongBackground()
    local bg = song:GetBackgroundPath()
    local isvid = false
    if bg then
        local folder = string.sub(bg,string.find(bg,".+/"))
        for _,v in ipairs({GAMESTATE:GetFileStructure(folder)}) do
            if vid[string.lower(string.gsub(v,".+%.",""))] then
                bg = folder .. v
                isvid = true
            end
        end
    end
    return bg, isvid
end

local function update()
    if isPlaying then
        if jukebox.SongPositions(0.2) >= song:MusicLengthSeconds() then
            if isAutoplay then
                jukebox.NextSong()
            else
                prev = song
                song = nil
                isPlaying = false
            end
        end
    end
end

event.Persist("update", "jukebox", update)
event.Persist("key func", "jukebox", function(c) 
    if c == "F4" then 
        jukebox.NextSong() 
        SCREENMAN:SystemMessage("Skipping song")
    end 
end)
return jukebox