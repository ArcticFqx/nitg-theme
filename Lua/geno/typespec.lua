local generic, runcommand
local typespec = {
    BitmapText = {
        Type = "BitmapText",
        File = "_eurostile normal",
        Init = function( actor, template )
            actor:settext( template.Text or "" )
            return generic.Init( actor, template )
        end
    },
    Shader = {
        File = "shader.xml",
        Init = function(actor, template)
            local dummy = actor:GetChild("shader")
            actor:hidden(1)
            dummy:hidden(1)
            local shader = dummy:GetShader()
            if template.Frag or template.Vert then
                local vert = template.Vert or stitch "lua.geno.vert"
                local frag = template.Frag or stitch "lua.geno.frag"
                print("RECOMPILING", shader)
                shader:compile(vert, frag)
            end
            return template.InitCommand(shader, template)
        end,
        On = function() end
    },
    ActorFrame = { },
    Quad = { Type = "Quad" },
    Text = { Type = "BitmapText" },
    ActorFrameTexture = { Type="ActorFrameTexture" },
    AFT = { Type = "ActorFrameTexture" },
    Polygon = { Type = "Polygon" },
    Poly = { Type = "Polygon" },
    ActorMultiVertex = { Type = "Polygon" },
    ActorSound = { Type = "ActorSound" },
    Sound = { Type = "ActorSound" },
    Audio = { Type = "ActorSound" },
    Actor = { Type = "Actor" },
    Aux = { Type = "Actor" }
}

local function runcommand(actor, template, kind)
    local func = template[kind]
    if func then
        if type(func) == "string" then
            actor:cmd(func)
        elseif type(func) == "function" then
            return func(actor, template)
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