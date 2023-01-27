-- 测试自定义node的功能场景
local TestScene = class("TestScene", function ()
    return display.newScene("TestScene")
end)

function TestScene:ctor()
    local logo = require("app.LogoNode").new():addTo(self):center() 
end

return TestScene