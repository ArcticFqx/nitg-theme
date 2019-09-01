local screen = stitch "lua.screen"
local jukebox = stitch "lua.jukebox"

local gameplay = {}

local cursong = nil

function gameplay.Goto( song )
    cursong = song.Song or song
    screen.SetNewScreen "PlayGame"
end

function gameplay:On()
    stitch "lua.show" (self:GetChildren())
end

function gameplay.NextScreen( )
    GAMESTATE:JoinPlayer(0)
    GAMESTATE:JoinPlayer(1)
    
    GAMESTATE:ApplyGameCommand("game,dance;playmode,regular;style,versus")

    if not cursong then
        cursong = SONGMAN:GetRandomSong()
    end

    GAMESTATE:SetCurrentSong(cursong)
    local steps = cursong:GetAllSteps()[1]
    GAMESTATE:SetCurrentSteps(0,steps)
    GAMESTATE:SetCurrentSteps(1,steps)

    jukebox.Pause()
    jukebox.NextSong(cursong, true)
    jukebox.AutoNext(false)

    cursong = nil
end

function gameplay.PrevScreen()
    screen.Prepare("TitleScreen")
    jukebox.NextSong()
    jukebox.AutoNext(true)
    return screen.Next()
end

return gameplay