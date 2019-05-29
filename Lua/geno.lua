-- If you edit template.xml, reflect the change here
local nodesPerAF = 10
local templatepath = "template.xml"

-- End of config

--[[ 
    Geno is a library for creating screens in a similar way 
    to how SM5's Def tables work.

    Part of the nitg-theme project: https://github.com/ArcticFqx/nitg-theme/
]]

local geno = { 
    Actors = {}, 
    ActorByName = {}, 
    NameByActor = {},
    TemplateByActor = {},
    ActorFrame = {},
    Overlay = { _ = "ignore", n = 0 }
}

local log = nodesPerAF == 10
            and math.log10
            or  function(n)
                    return math.log(n)/math.log(nodesPerAF) 
                end

local stack = {}

local ceil = math.ceil
local getn = table.getn
local lower = string.lower

local typespec = stx("lua.geno.typespec")

local function GetDepth(t)
    local depth = ceil(log(getn(t)))
    return depth > 0 and depth or 1
end

local smeta = {}

function smeta:Push(entry)
    self[getn(self) + 1] = entry
end

function smeta:Pop()
    local t = self[getn(self)]
    self[getn(self)] = nil
    return t
end

function smeta:Top()
    return self[getn(self)]
end

function smeta:NewLayer(t)
    self:Push {
        template = t, -- current layer
        depth = GetDepth(t), -- depth of tree structure
        width = getn(t), -- width of layer
        cd = 1, -- current depth
        i = 0, -- current template index
        l = {}, -- current index of node
        a = {} -- geno.Actors clone
    }
end

smeta.__index = smeta

function geno.RegisterOverlay(a)
    local name = a:GetName()
    if geno.Overlay[name] then return end
    if name == "" then
        geno.Overlay.n = geno.Overlay.n+1
        name = tostring(geno.Overlay.n)
        a:SetName(name)
    end
    geno.Overlay[a] = name
    geno.Overlay[name] = a
end

-- This runs first
function geno.Cond(index, type)
    local s = stack:Top()
    s.l[s.cd] = index
    
    if s.width <= s.i then
        return false
    end
    return true
end

function geno.Type()
    local s = stack:Top()
    if s.cd < s.depth then
        return
    end
    s.i = s.i + 1
    local template = s.template[s.i]
    if lower(template.Type) == "actorframe" then
        if table.getn(template) > 0 then
            return
        end
    end
    if typespec[template.Type].Type then
        template.Type = typespec[template.Type].Type
    end
    return typespec[template.Type].Type
end

-- This runs second
function geno.File()
    local s = stack:Top()

    if s.cd < s.depth then
        s.cd = s.cd + 1
        print("Depth["..table.getn(stack).."]:", s.cd-1, "->", s.cd)
        return templatepath
    end

    local template = s.template[s.i]

    if lower(template.Type) == "actorframe" then
        if table.getn(template) > 0 then
            stack:NewLayer(template)
            s.a[s.i] = stack:Top().a
            print("NewAF["..table.getn(stack).."]:", 0, "->", 1)
            return templatepath
        end
    end

    if template.File then
        local rel = string.find(template.File, "^/") and "../" or ""
        return rel .. template.File
    end

    return typespec[template.Type].File
end

-- This runs third
function geno:Init()
    print("Geno::Initalize", self)
    local s = stack:Top()
    
    if s.cd < 1 then
        s.a[0] = self
        geno.ActorFrame[self] = s.a
        stack:Pop()
        s = stack:Top()
    end
    local template = s.template[s.i]

    if s.cd == s.depth then
        if not s.a[s.i] then
            s.a[s.i] = self
        end
        geno.TemplateByActor[self] = template
        if template.Name then
            geno.ActorByName[template.Name] = self
            geno.NameByActor[self] = template.Name
            self:SetName(template.Name)
        end
        typespec[template.Type].Init(self, template)
    else
        self:SetName("_")
    end

    if s.l[s.cd] >= nodesPerAF or s.width <= s.i then
        s.cd = s.cd - 1
        print("Depth["..table.getn(stack).."]:", s.cd+1, "->", s.cd)
    end
end

-- These runs at the very end when everything has been built
function geno:InitCmd()
    local s = stack:Top()
    local template = s.template
    geno.Actors[0] = self
    geno.TemplateByActor[self] = template
    if template.Name then
        geno.ActorByName[template.Name] = self
        geno.NameByActor[self] = template.Name
        self:SetName(template.Name)
    end
    typespec[template.Type].Init(self, template)
end

-- OnCommand Time
function geno.OnCmd(_, a)
    a = a or geno.Actors
    for k,v in ipairs(a) do
        if type(v) == "table" then
            geno.OnCmd(_, v)
        else
            typespec[v].On(v, geno.TemplateByActor[v])
        end
    end
    typespec[a[0]].On(a[0], geno.TemplateByActor[a[0]])
end

-- Called from Root
function geno.Template(template)
    geno.Actors = {}
    geno.ActorByName = {}
    geno.NameByActor = {}
    geno.TemplateByActor = {}
    geno.ActorFrame = {}
    stack = setmetatable({},smeta)
    stack:NewLayer(template)
    local s = stack:Top()
    s.a = geno.Actors
    print("Depth["..table.getn(stack).."]:", s.cd-1, "->", s.cd)
    return true
end

geno.Def = {}
function geno.Def:__index(k)
    return function(t)
        t.Type = k
        return t
    end
end
setmetatable(geno.Def, geno.Def)

return geno