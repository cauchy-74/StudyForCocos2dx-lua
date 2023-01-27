-- 自定义node

local LogoNode = class("LogoNode", function ()
    return display.newNode()
end)

function LogoNode:ctor()
    local btn = display.newSprite("image/button.png"):addTo(self) 
    local bg  = display.newSprite("image/GameBackground.png"):addTo(self)

    bg:setVisible(false) 

    -- 3s 切换Sprite 
    self:getScheduler():scheduleScriptFunc(function (f)
        btn:setVisible(not btn:isVisible())
        bg:setVisible(not bg:isVisible())
    end, 3, false) 

end

return LogoNode 