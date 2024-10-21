local module = {}
function module.isInternetOn()
    local pingSuccess = (game:HttpGet("example.com") and true) or false
    repeat task.wait() until pingSuccess ~= nil
    return pingSuccess
end

return module
--Usage: repeat task.wait() until module.isInternetOn() ~= false print("Internet is on!")
