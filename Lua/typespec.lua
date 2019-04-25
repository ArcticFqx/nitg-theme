function runcommand(actor, template, kind)
    local func = template[kind]
    if func then
        if type(func) == "string" then
            actor:cmd(func)
        elseif type(func) == "function" then
            func(actor)
        end
    end
end

local generic = {
    Init = function (actor, template)
        actor:xy(template.X or 0, template.Y or 0)
        runcommand(actor, template, "InitCommand")
    end,
    On = function (actor, template)
        runcommand(actor, template, "OnCommand")
    end
}

local typespec = {
    BitmapText = {
        Init = function( actor, template )
            actor:settext( template.Text or "" )
            generic.Init( actor, template )
        end,
        On = generic.On,
        Type = "BitmapText"
    },
    ActorFrameTexture = {
        Type="ActorFrameTexture",
        Init = generic.Init,
        On = generic.On
    },
    Quad = {
        Type="Quad",
        Init = generic.Init,
        On = generic.On
    }
}

setmetatable( typespec, {
    __index = function()
        return generic
    end
})

return typespec