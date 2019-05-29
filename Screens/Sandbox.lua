local event = stitch "lua.event"
local screen = stitch "lua.screen"
local UI = stitch "lua.ui"

local function bmtInit(self)
    self:halign(0)
    self:valign(0)

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

        if c == "escape" then
            stitch "lua.screen" . SetNewScreen "TitleScreen"
        end
    end)

    self:zoom(0.5)
end

return Def.ActorFrame {
    Name="MainActorFrame",
    Def.Sprite{ -- rainbow background
        Name="BG",
        File="/Graphics/rainbow.jpg",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y,
        InitCommand="zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;diffuse,0.4,0.4,0.4,1"
    },
    Def.BitmapText{ -- Lua scratch pad
        Name="button",
        File="/Fonts/_eurostile outline",
        Text="",
        X = 10, Y = 10,
        OnCommand=bmtInit
    }
}