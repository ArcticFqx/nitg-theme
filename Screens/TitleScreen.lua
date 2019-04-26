local event = stitch "lua.event"
local screen = stitch "lua.screen"
local spc = stitch "lua.keyboard".special
local buf = stitch "lua.keyboard".buffer

local logo = {}
local songName
local layout = Def.ActorFrame {
    Name="MainActorFrame",
    Def.Sprite{
        Name="BG",
        File="/Graphics/rainbow.jpg",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y,
        InitCommand=function(self)
            self:zoomto(SCREEN_WIDTH,SCREEN_HEIGHT)
            self:diffusealpha(0.5)
        end
    },
    Def.Sprite{
        File="/Graphics/nitglogo.png",
        X=SCREEN_CENTER_X+2, Y=SCREEN_CENTER_Y/2+2,
        InitCommand=function(self)
            logo[1] = self
            self:zoom(SCREEN_HEIGHT/2/SCREEN_HEIGHT)
            self:diffusecolor (0,0,0,1)
            self:diffusealpha (0.5)
        end
    },
    Def.Sprite{
        File="/Graphics/nitglogo.png",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y/2,
        InitCommand=function(self)
            logo[2] = self
            self:zoom(SCREEN_HEIGHT/2/SCREEN_HEIGHT)
        end
    },
    Def.BitmapText{
        Name="button",
        File="/Fonts/_eurostile outline",
        Text="",
        X = SCREEN_CENTER_X, Y = SCREEN_CENTER_Y+70,
        InitCommand=function(self)
            
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
    },
    Def.Quad {
        X=10, Y=10,
        InitCommand="valign,1;x,SCREEN_CENTER_X;y,SCREEN_HEIGHT;zoomto,SCREEN_WIDTH,24;diffuse,0,0,0,0.5"
    },
    Def.BitmapText{
        File="/Fonts/_lato stroke 48px [main]",
        Text="!",
        X = 30, Y = SCREEN_HEIGHT-6,
        InitCommand=function(self) 
            self:halign(0)
            self:valign(1)
            self:zoom(0.3)
            songName = self
        end
    },
    Def.Sprite {
        File="/Graphics/note-48.png",
        X = 4, Y = SCREEN_HEIGHT-4,
        InitCommand=function(self) 
            self:halign(0)
            self:valign(1)
            self:zoom(0.3)
        end
    },
    Def.Audio {
        File="/Music/dummy.wav",
        InitCommand=function(self)
            local song
            local prev
            local prevSong = ""
            local curSong = ""

            local function formatName(song)
                return song:GetDisplayArtist() .. 
                    "  -  " .. song:GetDisplayMainTitle()
            end

            local function nextSong()
                prevSong = song and formatName(song) or ""
                song = SONGMAN:GetRandomSong()
                self:load(song:GetMusicPath())
                self:start()
                curSong = formatName(song)
                prev = -1
            end

            local mod = 0
            event.Add("update", "song", function()
                mod = math.mod(mod,10) + 1
                local sp = self:get():GetSoundPosition()
                local beat = 1+math.mod(song:GetBeatFromElapsedTime(sp or 0)+0.1,1)/10
                local size = SCREEN_HEIGHT/2/SCREEN_HEIGHT*beat
                logo[1]:zoom(size)
                logo[2]:zoom(size)
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
                        songName:settext(string.sub(prevSong,0,string.len(prevSong)*(1-sp)))
                    else
                        sp = sp -1
                        songName:settext(string.sub(curSong,0,string.len(curSong)*sp))
                    end
                end
            end)

            event.Add("input", "nextsong", function(c, p)
                if c == "Right" and p then
                    nextSong()
                end
            end)

            nextSong()
        end
    }
}

return layout