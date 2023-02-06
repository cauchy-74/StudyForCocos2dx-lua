---@diagnostic disable: duplicate-set-field

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local Manager = require("app.scenes.Manager")

function MainScene:ctor()
    local background = display.newSprite("GameBackground.png", display.cx, display.cy)
        :addTo(self)
    
    local manager = Manager.new()
    self:addChild(manager)
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
