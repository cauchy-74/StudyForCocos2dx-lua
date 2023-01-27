
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

package.path = package.path .. ";src/?.lua;src/framework/protobuf/?.lua"

-- local function main() 
--     local mainScene = require("app.MyApp")
--     cc.Director:getInstance():runWithScene(mainScene)
-- end

-- xpcall(main, __G__TRACKBACK__)

require("app.MyApp").new():run()