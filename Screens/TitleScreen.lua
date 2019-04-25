local event = stitch "lua.event"
local screen = stitch "lua.screen"
local spc = stitch "lua.keyboard".special
local buf = stitch "lua.keyboard".buffer

local function init()
    local byname = stitch("lua.geno").ActorByName

    --byname.start:start()

    local st = os.clock()
    local startlen = 3.86

    --[[
    event.Add("update","initloop",function(t)

        if (t-st) > startlen then
            byname.loop:start()
            event.Add("input",screen,function(key, press)
                if press then
                    --screen.SetNewScreen("Meow")
                end
            end)
            local rs = byname.loop:get()
            local bt = 60/125
            event.Add("update","loop",function()
                local a = math.mod((rs:GetSoundPosition()+bt)/bt,2)
                byname.BG:diffusealpha(a<=1 and 0.5 or 1)
            end)
            byname.button:hidden(0)
            event.Remove("update","initloop")
        end
    end)
    ]]

end


local layout = Def.ActorFrame {
    InitCommand = init,
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
            self:zoom(SCREEN_HEIGHT/2/SCREEN_HEIGHT)
            self:diffusecolor (0,0,0,1)
            self:diffusealpha (0.5)
        end
    },
    Def.Sprite{
        File="/Graphics/nitglogo.png",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y/2,
        InitCommand=function(self)
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
    Def.Audio{
        File="/Music/dummy.wav",
        InitCommand=function(self)
            self:start()
        end
    }
    --[[,,
    Def.BitmapText{
        File="/Fonts/_lato stroke 48px [main]",
        Text="Press the any key to begin!",
        X = SCREEN_CENTER_X, Y = SCREEN_CENTER_Y+170,
        InitCommand="hidden,0"
    }
    Def.Audio{
        File="/Music/titlestart.ogg",
        Name="start"
    },
    Def.Audio{
        File="/Music/titleloop.ogg",
        Name="loop"
    }]]
}

return layout