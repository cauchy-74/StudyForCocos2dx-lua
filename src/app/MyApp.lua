
require("config")
require("cocos.init")
require("framework.init")

local AppBase = require("framework.AppBase")
local MyApp = class("MyApp", AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")

    -- 导入 plist, png 
    display.addSpriteFrames("Item.plist", "Item.png")

    function cclog( ... ) print(...) end

    self:enterScene("MainScene")
end

return MyApp
