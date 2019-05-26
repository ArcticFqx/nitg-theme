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

function jukebox.GetSongBackground()
    return song:GetBackgroundPath()
end

local function update()
    if isPlaying then
        if  (sound:get():GetSoundPosition()+0.1) 
            >= song:MusicLengthSeconds() then
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

return jukebox