local generic
local typespec = {
    ActorFrame = { Type="ActorFrame" },
    Quad = { Type="Quad" },
    BitmapText = {
        Type = "BitmapText",
        Init = function( actor, template )
            actor:settext( template.Text or "" )
            return generic.Init( actor, template )
        end
    },
    Text = { Type="BitmapText" },
    ActorFrameTexture = { Type="ActorFrameTexture" },
    AFT = { Type="ActorFrameTexture" },
    Polygon = { Type="Polygon" },
    Poly = { Type="Polygon" },
    ActorMultiVertex = { Type="Polygon" },
    ActorSound = { Type="ActorSound" },
    Sound = { Type="ActorSound" },
    Audio = { Type="ActorSound" }
}


local function runcommand(actor, template, kind)
    local func = template[kind]
    if func then
        if type(func) == "string" then
            actor:cmd(func)
        elseif type(func) == "function" then
            return func(actor)
        end
    end
end

generic = {
    Init = function (actor, template)
        actor:xy(template.X or 0, template.Y or 0)
        return runcommand(actor, template, "InitCommand")
    end,
    On = function (actor, template)
        return runcommand(actor, template, "OnCommand")
    end
}

setmetatable( typespec, {
    __index = function()
        return generic
    end
})

local tsmeta = { __index = generic }
for _,v in pairs(typespec) do
    setmetatable(v, tsmeta)
end

return typespec