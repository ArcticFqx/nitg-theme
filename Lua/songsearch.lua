local search = {}
local songs = SONGMAN:GetAllSongs()
local lookup = {}
local lower, gsub, find = string.lower, string.gsub, string.find

for i=1, table.getn(songs) do
    local v = songs[i]
    lookup[lower(v:GetTranslitArtist() .. " " .. v:GetTranslitFullTitle())] = v
end

local r = {
    ["%"] = "%%[^ ]-", ["("] = "%([^ ]-", [")"] = "%)[^ ]-", ["+"] = "%+[^ ]-",
    ["-"] = "%-[^ ]-", ["*"] = "%*[^ ]-", ["?"] = "%?[^ ]-", ["["] = "%[[^ ]-",
    ["^"] = "%^[^ ]-", ["$"] = "%$[^ ]-", ["."] = "%.[^ ]-", [" "] = ".-"
}

function search.Find( s )
    s = lower(gsub(gsub(gsub(s, " +"," "),"^ ",""),".",function(a)
        return r[a] or (a .. "[^ ]-")
    end))
    local res = {}
    if s == "" then return res end
    for k, v in pairs(lookup) do
        if find(k,s) then
            res[k] = v
        end
    end
    return res
end

return search