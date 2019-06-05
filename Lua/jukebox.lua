local event = stitch "lua.event"
local sound = stitch "lua.geno" .Overlay.Music

local jukebox = {}

local song, prev
local isPlaying = false
local isAutoplay = false

function jukebox.NextSong()
    print("Just played:", jukebox.CurrentSong())
    prev = song
    song = SONGMAN:GetRandomSong()
    print("Now playing:", jukebox.CurrentSong())
    sound:load(song:GetMusicPath())
    sound:start()
    GAMESTATE:SetCurrentSong(song)
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
        return  song:GetTranslitArtist(), 
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
    local pos = sound:get():GetSoundPosition() + (offset or 0)
    return pos, song:GetBeatFromElapsedTime(pos)
end

function jukebox.IsPlaying()
    return IsPlaying
end

local vid = {
    avi = true, mpg = true, mpeg = true
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

event.Persist("overlay update", "jukebox", update)
event.Persist("kb char", "jukebox", function(c) 
    if c == "F4" then 
        jukebox.NextSong() 
        SCREENMAN:SystemMessage("Skipping song")
    end 
end)
return jukebox