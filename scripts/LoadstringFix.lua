local g = getgenv()
local p = pcall
local native_ls = g.old_ls or loadstring

g.old_ls = native_ls
g.loadstring = function(s)
    local _, res = p(native_ls, s)
    return res
end
