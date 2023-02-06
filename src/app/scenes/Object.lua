local object = class("object", function ()
    return display.newSprite()
end)

function object:ctor()
    self.ID = 0 
    -- 对应矩阵中xy位置坐标
    self.posX, self.posY = 0, 0 
    self.Manager = {} 
end

function object:setInfo(ID) 
    self.ID = ID 
    local frameName = string.format("Item%d.png", ID) 
    local frame = display.newSpriteFrame(frameName)
    self:setSpriteFrame(frame) 
end 

function object:moveToGrid(x, y)
    local targetX = self.Manager.startPos.x + self.Manager.bubbleLen * (y - 1)
    local targetY = self.Manager.startPos.y + self.Manager.bubbleLen * (x - 1) 
    local moveAction = cc.MoveTo:create(0.3, cc.p(targetX, targetY))
    self:runAction(moveAction) 
end

return object 