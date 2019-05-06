local UI = stitch "lua.ui"
local event = stitch "lua.event"
local geno = stitch "lua.geno"
local Def = geno.Def

local function construct ( t )
    local af = Def.ActorFrame( t )
    af.UI = "Frame"
    

    local cursor = 1
    function af:InitCommand()
        local actors = geno.ActorFrame[self]
        local n = table.getn(actors)
        for i,v in ipairs(actors) do
            v:y((v:GetHeight()+t.Padding)*(i-1))
        end
        if t.Active then
            actors[1]:cmd(t.OnHover)
            event.Add("input","ui title", function(key,press)
                if not press then return end

                local dir = key == "Down" and 1 or
                            key == "Up" and -1
                if dir then
                    actors[cursor]:cmd(t.OnExit)
                    cursor = math.mod(cursor+dir,n)
                    if cursor < 1 then
                        cursor = n
                    end
                    actors[cursor]:cmd(t.OnHover)
                end

                if key == "Start" then
                    geno.TemplateByActor[actors[cursor]].OnSelect()
                end
            end)
        end
    end

    return af
end

return construct
