local scale = 0.6

function ready(af)
    local self = af.DevConsole
    print(self)
    local event = stitch "lua.event"
    local config = stitch "config"
    local enabled = false
    local DevConsole = self
    local DevBuffer = af.DevBuffer
    local DevInput = af.DevInput
    local DevBackground = af.DevBackground
    print(self,DevBuffer,DevInput,DevBackground)
    
    local buffer = {"","","","","","","","","","","","","","",""}
    local history = {cur = 0}
    local debug = Debug
    local trace = Trace
    local print = print
    local screenman = getmetatable(SCREENMAN)
    local sysmsg = screenman.SystemMessage

    local height = DevBuffer:GetHeight()
    local quadheight = 10+height*20*scale
    DevBuffer:x(10) 
    DevBuffer:y(10+height*17*scale)
    DevInput:x(10)
    DevInput:y(20+height*18*scale)
    DevBackground:zoomto(SCREEN_WIDTH, quadheight)
    DevConsole:y(-quadheight)

    local function append(msg)
        table.remove(buffer, 1)
        table.insert(buffer, msg)
        if enabled then
            DevBuffer:settext(table.concat(buffer,"\n"))
        end
    end

    function Trace(msg)
        trace(msg)
        append(msg)
        return true
    end

    function Debug(msg)
        debug(msg)
        append(msg)
        return true
    end

    function screenman:SystemMessage(msg)
        sysmsg(SCREENMAN, msg)
        append(msg)
    end

    function _G.print(...)
        print(unpack(arg))
        for i=1,table.getn(arg) do
            arg[i] = tostring(arg[i])
        end
        append(table.concat(arg,"  "))
    end

    local function show(s)
        if string.len(s) <= 0 then return end
        append(s)
        if s == "> " then return end
        print(s)
    end

    local function tab(num, con)
        return string.rep("  ", num or 0) .. con
    end

    local function GetChildren(af)
        local ret = {}
        for i=1,af:GetNumChildren() do
            ret[i+1] = af:GetChildAt(i-1)
        end
        return ret
    end

    local function printtable(t, deep, rec)
        rec = rec or {}
        rec[t] = t
        local vs
        if type(t) == "userdata" then
            local hasChildren = t:GetNumChildren() > 0
            vs = string.format("%s[%s]", string.gfind(tostring(t),"[^%s]+")(), t:GetName())
            if hasChildren then
                t = GetChildren(t)
                show(tab(deep,vs..":"))
            else
                show(tab(deep,vs))
                return
            end
        end
        show(tab(deep,"{"))
        for k,v in pairs(t) do
            local vt = type(v)
            vs = nil
            if vt == "userdata" and v.GetName then
                vs = string.format("%s[%s]", string.gfind(tostring(v),"[^%s]+")(), v:GetName())
                if v.GetText then
                    vs = vs..": ".. v:GetText()
                end
                if v.GetTexture and v:GetTexture() then
                    vs = vs..": ".. v:GetTexture():GetPath()
                end
                if v.GetNumChildren then
                    local num = v:GetNumChildren()
                    if num > 0 and deep then
                        vs = vs..":"
                    elseif num > 0 then
                        vs = vs..": " .. num .. (num>1 and " children" or " child")
                    end
                end
            end
            show(tab(deep,"  " .. tostring(k) .. " = " .. tostring(vs or v)))
            if deep and (vt == "table" or vt == "userdata" and v.GetNumChildren) and not rec[v] then
                if vt == "table" then
                    printtable(v,deep+1, rec)
                elseif v:GetNumChildren() > 0 then
                    printtable(GetChildren(v), deep+1, rec)
                end
            end
        end
        show(tab(deep,"}"))
    end

    local function eval(code)
        local fn,err,erralt
        fn, err = loadstring(
            string.format("return (function(...) return arg end)(%s)",code),"Console")
        if not fn then
            fn, erralt = loadstring(code,"Console")
        end
        err = erralt or err
        if fn then
            local ret = {pcall(
                function()
                    return (function(...)
                        return arg
                    end)(fn())
                end
            )}
            if ret[1] then
                return err and ret[2] or ret[2][1]
            else
                err = ret[2]
            end
        end

        show(string.gsub(err,"^.-:1: ","error: "))
    end

    local function toggleCheck(char, special)
        return char == config.console 
                and special.ctrl and not special.altgr
    end

    event.Persist("key char","dev console",function(char, special)
        if not toggleCheck(char, special) then return end
        enabled = not enabled
        DevConsole:finishtweening()
        if not enabled then
            DevConsole:accelerate (0.3)
            DevConsole:y(-quadheight)
            event.Timer(0.4,function()
                if enabled then return end
                DevConsole:hidden(1)
                DevInput:settext("")
                SCREENMAN:SetInputMode(0)
            end)
            event.Remove("key char", "dev input")
            event.Remove("key func", "dev input")
            return
        end

        DevBuffer:settext(table.concat(buffer,"\n"))
        DevConsole:visible(1)
        DevConsole:decelerate(0.3)
        DevConsole:y(0)

        SCREENMAN:SetInputMode(2)

        event.Timer(0.5,function()
            local charray = {}
            event.Persist("key char", "dev input", function(char, special)
                if toggleCheck(char, special) then return end
                if char == "\n" then
                    local deep = charray[1] == "!"
                    local text = table.concat(charray, "", deep and 2 or 1)
                    history[table.getn(history) + 1] = charray
                    DevInput:settext("")
                    history.cur = table.getn(history)+1
                    show("> " .. text)
                    local res = eval(text)
                    if res then
                        if type(res) == "table" then
                            if type(res[1]) == "table" and res.n == 1 then
                                if deep then deep = 0 else deep = nil end
                                printtable(res[1], deep)
                            elseif type(res[1]) == "userdata" and res.n == 1 and res[1].GetNumChildren then
                                if deep then deep = 0 else deep = nil end
                                printtable(res[1], deep)
                            else
                                for i=1,res.n or table.getn(res) do
                                    res[i] = tostring(res[i])
                                end
                                show(table.concat(res,"  "))
                            end
                        else
                            show(tostring(res))
                        end
                    end
                    charray = {}
                else
                    table.insert(charray, char)
                    DevInput:settext(table.concat(charray))
                end
            end)
            event.Persist("key func","dev input", function(char)
                if char == "backspace" then
                    table.remove(charray)
                    DevInput:settext(table.concat(charray))
                    return
                end
                local scroll = char == "up" and -1 or char == "down" and 1 or 0
                if scroll ~= 0 then
                    local cur = history.cur + scroll
                    if not history[cur] then return end
                    history.cur = cur
                    charray = history[cur]
                    DevInput:settext(table.concat(charray))
                end
                if char == "escape" then
                    DevInput:settext("")
                    charray = {}
                    history.cur = table.getn(history)+1
                end
            end)
        end)
    end)
end

return Def.ActorFrame {
    OnReady = ready,
    Name = "DevConsole",
    InitCommand = "hidden,1",
    Def.Quad {
        Name = "DevBackground",
        InitCommand = "align,0,0;diffuse,0,0.1,0,0.7"
    },
    Def.Text {
        Name = "DevBuffer",
        InitCommand = "align,0,1;diffuse,0.9,1,0.9,1;zoom," .. scale,
        File = "/Fonts/_eurostile outline",
        Text = "|"
    },
    Def.Text {
        Name = "DevInput",
        File = "/Fonts/_eurostile outline",
        InitCommand = "align,0,1;zoom," .. scale
    }
}