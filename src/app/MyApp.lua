
require("config")
require("cocos.init")
require("framework.init")

local AppBase = require("framework.AppBase")
local MyApp = class("MyApp", AppBase)

function cclog( fmt, ... )
    print(fmt, ...)
end

function MyApp:ctor()
    MyApp.super.ctor(self)
end

function MyApp:run()
    cc.FileUtils:getInstance():addSearchPath("res/")
    -- self:enterScene("TestScene") -- 3s 变换一个scene
    self:enterScene("MainScene")
end

return MyApp
