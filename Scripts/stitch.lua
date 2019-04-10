-- -- -- -- -- -- -- -- -- --
-- Forked from LibActor    --
-- Stitch global reference --
-- -- -- -- -- -- -- -- -- --

if _G.stitch then
    Trace("[Stitch] Reusing old stitch")
    Trace('[Stitch] We are on version "' .. stitch._VERSION .. '"')
    return
end

local stitch = {
    _LAXVER = 'LibActor 0.5.0',
    _VERSION = 'Stitch 190325 dev'
}

_G.stitch = stitch
_G.stx = stitch

local gsub, lower, find, gfind = string.gsub, string.lower, string.find, string.gfind
local getn, loadfile, Debug, type = table.getn, loadfile, Debug, type
local setfenv, setmetatable = setfenv, setmetatable
local unpack, Trace, sub, pairs = unpack, Trace, string.sub, pairs

local folder = '/'..THEME:GetCurThemeName()..'/'
local addFolder = lower(PREFSMAN:GetPreference('AdditionalFolders'))
local add = './themes,' .. gsub(addFolder, ',' ,'/themes,') .. '/themes'
local hit = ''

local function load(name)
    local file = gsub(lower(name), '%.', '/') .. '.lua'
    local log={}
    for w in gfind(hit .. add,'[^,]+') do
        local path = gsub(w .. folder .. file, '/+', '/')
        local func, err = loadfile(path)
        if func then
            hit = w .. ','
            Debug('[Loading] ' .. path)
            return func
        end
        log[getn(log)+1] = '[Error] ' .. gsub(err,'\n.+','')
    end

    for i=1, table.getn(log) do
        if not find(log[i], 'cannot read') then Debug(log[i]) return end
    end
    Debug(log[1])
end

local requireCache = {}
-- Require with a search path in your song directory, caches path hits and results
function stitch.RequireEnv(name, env, ...)
    name = lower(name)
    if requireCache[name] then
        return unpack(requireCache[name])
    end
    local func = load(name)
    if not func then
        return
    end

    env = env or {}
    env.arg = arg

    setfenv( func, setmetatable(
        env,
        { __index = _G, __newindex = _G }
    ))
    requireCache[name] = {func()}
    return unpack(requireCache[name])
end

function stitch.Require( name, ... )
    return stitch.RequireEnv(name, nil, unpack(arg))
end

function stitch:__call(name, ...)
    return stitch.RequireEnv(name, nil, unpack(arg))
end

-- And we are done!
setmetatable(stitch, stitch)

Trace '[Stitch] Initialized!'
Trace('[Stitch] We are on version "' .. stitch._VERSION .. '"')

return stitch