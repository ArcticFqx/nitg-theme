local scale = 0.6
local function ready(overlay)
    local event = stitch "lua.event"
    local enabled = false
    local DevBuffer = overlay.DevBuffer
    local DevConsole = overlay.DevConsole
    local DevInput = overlay.DevInput
    local DevBackground = overlay.DevBackground
    
    local buffer = {"","","","","","","","","","","","","","",""}
    local debug = Debug
    local trace = Trace
    local print = print
    local screenman = getmetatable(SCREENMAN)
    local sysmsg = screenman.SystemMessage

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


    local height = DevBuffer:GetHeight()
    local quadheight = 10+height*20*scale
    DevBuffer:xy(10,10+height*17*scale)
    DevInput:xy(10,20+height*18*scale)
    DevBackground:zoomto(SCREEN_WIDTH, quadheight)
    DevConsole:y(-quadheight)

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

    event.Persist("kb char","dev console",function(char)
        if char ~= "|" then return end
        enabled = not enabled
        event.Ignore("input", enabled)
        DevConsole:finishtweening()
        if not enabled then
            DevConsole:accelerate (0.3)
            DevConsole:y(-quadheight)
            event.Timer(0.4,function()
                if enabled then return end
                DevConsole:hidden(1)
                DevInput:settext("")
            end)
            event.Remove("kb char", "dev input")
            event.Remove("kb special", "dev input")
            return
        end

        DevBuffer:settext(table.concat(buffer,"\n"))
        DevConsole:visible(1)
        DevConsole:decelerate(0.3)
        DevConsole:y(0)
        event.Timer(0.5,function()
            event.Persist("kb char", "dev input", function(char)
                local text = DevInput:GetText()
                if char == "\n" then
                    DevInput:settext("")
                    show("> " .. text)
                    local res = eval(text)
                    if res then
                        if type(res) == "table" then
                            for i=1,res.n or table.getn(res) do
                                res[i] = tostring(res[i])
                            end
                            show(table.concat(res,"  "))
                        else
                            show(tostring(res))
                        end
                    end
                else
                    DevInput:settext(text .. char)
                end
            end)
            event.Persist("kb special","dev input", function(char)
                local text = DevInput:GetText()
                if char == "backspace" then
                    DevInput:settext(string.sub(text,1,string.len(text)-1))
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