local event = stx "lua.event"
local screen = stx "lua.screen"

local meow = {}
local il, layout 

local function init()
    event.Add("update","meow",function(t)
        for i=1,table.getn(meow) do
            local a = meow[i]
            local d = layout[il + i]
            a:x(d.X + math.sin(t*d.R)*50)
            a:y(d.Y + math.cos(t*d.R)*50)
        end
    end)
end


layout = Def.ActorFrame {
    Name="Meow",
    InitCommand = init,
    Def.Sprite{
        File="/Graphics/itg2.png",
        X=SCREEN_CENTER_X, Y=SCREEN_CENTER_Y,
        InitCommand="zoomto,SCREEN_WIDTH,SCREEN_HEIGHT;"
    },
    Def.Audio{
        File="/Music/jimmy.ogg",
        InitCommand="start"
    }
}

il = table.getn(layout)

for i=1,30 do
    local m = Def.BitmapText{
        File="Fonts/_lato stroke",
        Text="Meow",
        X = math.random()*SCREEN_WIDTH, 
        Y = math.random()*SCREEN_HEIGHT,
        R = math.random()*8-4
    }

    function m:InitCommand()
        print(self)
        meow[table.getn(meow)+1] = self
    end

    layout[table.getn(layout)+1] = m
end

return layout

