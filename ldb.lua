local sfind = string.find
local smatch = string.match
local sformat = string.format
local dgetinfo = debug.getinfo
local dsethook = debug.sethook
local dgetlocal = debug.getlocal
local dgetupvalue = debug.getupvalue
local iowrite = io.write
local in_iter = io.lines

local ldb = {}
local line = {}
local mode = "run"

local function infile(filename)
        for k, v in pairs(line) do
                if sfind(filename, k) ~= nil then
                        return k
                end
        end

        return nil
end

local function online(filename, linenr)
        if (filename == nil) then
                return false
        end

        for _, v in pairs(line[filename]) do
                if v == tostring(linenr) then
                        print("fdsafafa")
                        return true;
                end
        end

        return false
end

local function onstep()
        local info = dgetinfo(3, "Sluf")
        local head = sformat("%s:%d>", info.source, info.currentline)
        iowrite(head)
        for l in in_iter() do
                local cmd, param = smatch(l, "(%a+)%s*(%w*)")
                if cmd == "p" then --print variable
                        --local variable
                        for i = 1, 100 do
                                local n, v = dgetlocal(3, i)
                                if (n == nil) then
                                        break
                                end

                                if (n == param) then
                                        print(n, v)
                                        goto restart
                                end
                        end

                        for i = 1, info.nups do
                                local n, v = dgetupvalue(info.func, i)
                                if n == param then
                                        print(n, v)
                                        goto restart
                                end
                        end

                        print("noexist variable", param)
                elseif cmd == "c" then --continue run
                        mode = "run"
                        return ;
                elseif cmd == "s" then --step
                        if info.currentline >= info.lastlinedefined then
                                print("already step over function")
                                mode = "run"
                        end
                        return ;
                end

                ::restart::
                iowrite(head)
        end
end

local function line_hook()
        if mode == "step" then
                onstep()
        elseif mode == "run" then
                local info = dgetinfo(2, "Sl")
                if online(infile(info.source), info.currentline) then
                        print("in debug")
                        mode = "step"
                        onstep()
                end
        end


end

dsethook(line_hook, "l")

local function bline(param)
        local file, l = smatch(param, "(%w+%.%w+):(%w+)")
        if (file == nil or l == nil) then
                print("Please enter a valid parameter, line a.lua:3")
                return ;
        end

        if line[file] == nil then
                line[file] = {}
        end

        for _, v in pairs(line[file]) do
                if v == l then
                        return 
                end
        end

        table.insert(line[file], l)
end

local function bfunc(param)
        print("unsupport b function")
end

function ldb.input(iter)
        in_iter = iter
end

function ldb.b(param)
        if sfind(param, ":") ~= nil then
                bline(param)
        else
                bfunc(param)
        end
end

function ldb.d()
        line = {}
end

return ldb

