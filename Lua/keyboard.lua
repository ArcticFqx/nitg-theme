local event = stitch "lua.event"

local keyboard = {}

local layout = {
    Norwegian = "nor",
    Qwertz,
    QwertyUK
}

local lang = layout.Norwegian

local metabuf = {}
keyboard.buffer = setmetatable({}, metabuf)

local special = {
    backspace = false,
    shift = false,
    ctrl = false,
    alt = false,
    win = false,
    menu = false,
    altgr = false,
    escape = false
}

keyboard.special = special

local map = {
    nor = {
        remap = {
            space = " ", enter = "\n", tab = "\t", 
            ["`"] = "|", ["-"] = "+", ["["] = "å", ["]"] = "¨", ["\\"] = "'", [";"] = "ø", ["'"] = "æ", ["/"] = "-", ["="] = "\\"
        },
        shift = {
            ["1"] = "!", ["2"] = "\"", ["3"] = "#", ["4"] = "¤", ["5"] = "%", ["6"] = "&", ["7"] = "/", ["8"] = "(", ["9"] = ")", ["0"] = "=",
            ["|"] = "§", ["+"] = "?", ["å"] = "Å", ["¨"] = "^", ["'"] = "*", ["ø"] = "Ø", ["æ"] = "Æ", ["-"] = "_", ["\\"] = "`",
            [","] = ";", ["."] = ":"
        },
        altgr = {
            ["2"] = "@", ["3"] = "£", ["4"] = "$", ["5"] = "€", ["7"] = "{", ["8"] = "[", ["9"] = "]", ["0"] = "}",
            ["¨"] = "~", ["\\"] = "´", m = "µ"
        },
        alt = {
            ["'"] = "<", ["<"] = ">"
        }
    }
}

local function check(c)
    local map = map[lang]
    local char = map.remap[c] or c
    local out = char
    if special.shift then
        out = map.shift[char] or string.upper(char)
    end
    if special.altgr then
        out = map.altgr[char]
    end
    if special.alt and map.alt[char] then
        out = special.shift and map.alt[map.alt[char]] or map.alt[char]
    end
    return out
end

local cmd = {
    ["backspace"] = true,
    ["left shift"] = true,
    ["right shift"] = true,
    ["left ctrl"] = true,
    ["right ctrl"] = true,
    ["right meta"] = true,
    ["left meta"] = true,
    ["menu"] = true,
    ["left alt"] = true,
    ["right alt"] = true,
    ["escape"] = true
}

local text = ""
function keyboard:KeyHandler() 
    text = self:GetText()
end

function keyboard.Enable()
    event.Add("update", "keyboard", function()
        local keys = string.gfind(text,'Key_(.-) %-') 
        if not keys then return end

        local new = {}
        for match in keys do
            new[match] = true
        end
        

        special.backspace = new.backspace or false
        special.shift = new["left shift"] or new["right shift"] or false
        special.ctrl = new["left ctrl"] or new["right ctrl"] or false
        special.alt = new["left alt"] or new["right alt"] or false
        special.win = new["left meta"] or new["right meta"] or false
        special.menu = new.menu or false
        special.altgr = new["left ctrl"] and new["right alt"] or false
        special.escape = new.escape or false
        
        local buffer = keyboard.buffer

        for k in pairs(new) do
            if not buffer[k] then
                if not cmd[k] then
                    local c = check(k)
                    if c then
                        event.Call("kb char", c, special)
                    end
                else
                    event.Call("kb special", k)
                end
            end
        end

        metabuf.__index = new
        text = ""
    end)
end

return keyboard