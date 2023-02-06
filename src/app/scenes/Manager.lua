local Object = require("app.scenes.Object") 

local Manager = class("Manager", function ()
    return display.newLayer() 
end)

function Manager:ctor()
    math.randomseed(os.time()) 

    -- 矩阵长宽
    self.RowCount = 9 
    self.ColCount = 7 

    -- 泡泡起始位置，间隔大小
    self.startPos = cc.p(45, 100) 
    self.bubbleLen = 65 

    -- 泡泡列表容器 、 选择列表
    self.bubbleList = {} 
    self.explodeList = {} 

    self:init()

    self.preBubble = nil 
    self.lastBubble = nil 

    self.isCanTouch = true -- 防止action过程中，进行游戏操作

    -- score UI --
    self.score = 0 
    local label = display.newTTFLabel({
        text = "score:", 
        size = 64, 
        x = 100, 
        y = 750 
    }):addTo(self) 
    local scoreLabel = display.newTTFLabel({
        text = "001",
        size = 64, 
        x = 240,
        y = 750,
        align = cc.TEXT_ALIGNMENT_LEFT
    }):addTo(self)
    self.scoreLabel = scoreLabel
    -- score UI --

    -- [[监听触摸事件]]
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        cclog(event.name)
        if event.name == "began" then 
            if self.isCanTouch == false then 
                return true 
            end 
            self.preBubble = self:getObjectByPos(event.x, event.y)
            return true 
        elseif event.name == "ended" then
            if self.preBubble == nil then 
                return 
            end 
            self.lastBubble = self:getObjectByPos(event.x, event.y)
            if self.lastBubble ~= nil then 
                self:swap(self.preBubble, self.lastBubble)
            end 
            self.preBubble = nil
            self.lastBubble = nil 
            return true 
        end 
    end)
    self:setTouchEnabled(true)
end

--[[
    游戏初始化：
        1. 创建和设置场景中的格子和对象
]]
function Manager:init()
    -- 左下（1，1） x是从下网上，y是从左往右
    self.gridMap = {} -- 二维矩阵 
    for row = 1, self.RowCount do 
        self.gridMap[row] = {} 
        for col = 1, self.ColCount do 
            local bubble = Object.new() 
            local ID = math.random(1, 5) 
            bubble:setInfo(ID)
            bubble.Manager = self 
            bubble.posX = row
            bubble.posY = col 

            local x = self.startPos.x + self.bubbleLen * (col - 1)
            local y = self.startPos.y + self.bubbleLen * (row - 1) 
            bubble:pos(x, y):addTo(self, 4) 
            table.insert(self.bubbleList, bubble)
            
            local grid = display.newSprite(display.newSpriteFrame("ItemBack.png"), x, y):addTo(self, 0)

            self.gridMap[row][col] = bubble
        end 
    end 

    local action = cc.Sequence:create(cc.DelayTime:create(0.3), 
        cc.CallFunc:create(function ()
            while self:checkAndExplode() do end 
        end),
        cc.CallFunc:create(function ()
            self:fillNewItem();
        end)
    )
    self:runAction(action)
end

--[[
    根据点击位置获取响应的对象
]]
function Manager:getObjectByPos(x, y)
    for i = 1, #self.bubbleList do 
        local bubble = self.bubbleList[i] 
        local bubbleX, bubbleY = bubble:getPosition()
        if x >= bubbleX - self.bubbleLen / 2 and x <= bubbleX + self.bubbleLen / 2 and 
            y >= bubbleY - self.bubbleLen / 2 and y <= bubbleY + self.bubbleLen / 2 then 
            return bubble
        end 
    end 
    return nil 
end

--[[
    交换泡泡
        -- action，必须禁止操作【isCanTouch】
]]
function Manager:swap(bubbleA, bubbleB) 
    -- 1. 判断相邻【gridMap】
    local aPosX, aPosY = bubbleA.posX, bubbleA.posY
    local bPosX, bPosY = bubbleB.posX, bubbleB.posY 
    if aPosX == bPosX and math.abs(aPosY - bPosY) == 1 then 
    elseif aPosY == bPosY and math.abs(aPosX - bPosX) == 1 then 
    else return end 
    
    -- 2. 位置交换
    self.gridMap[aPosX][aPosY] = bubbleB
    bubbleB.posX = aPosX
    bubbleB.posY = aPosY

    self.gridMap[bPosX][bPosY] = bubbleA
    bubbleA.posX = bPosX
    bubbleA.posY = bPosY 

    -- 能否消除，不能就恢复交换
    if self:checkAndExplode(true) == false then 
        self.gridMap[aPosX][aPosY] = bubbleA
        bubbleA.posX = aPosX
        bubbleA.posY = aPosY

        self.gridMap[bPosX][bPosY] = bubbleB
        bubbleB.posX = bPosX
        bubbleB.posY = bPosY 

        local actionA = cc.Sequence:create(
            cc.CallFunc:create(function ()
                bubbleA:moveToGrid(bPosX, bPosY)
            end),
            cc.DelayTime:create(0.3), 
            cc.CallFunc:create(function ()
                bubbleA:moveToGrid(aPosX, aPosY)
            end)
        )
        bubbleA:runAction(actionA)

        local actionB = cc.Sequence:create(
            cc.CallFunc:create(function ()
                bubbleB:moveToGrid(aPosX, aPosY)
            end),
            cc.DelayTime:create(0.3), 
            cc.CallFunc:create(function ()
                bubbleB:moveToGrid(bPosX, bPosY)
            end)
        )
        bubbleB:runAction(actionB)
        return 
    end 

    self.isCanTouch = false 
    bubbleA:moveToGrid(bPosX, bPosY)
    bubbleB:moveToGrid(aPosX, aPosY)

    local action = cc.Sequence:create(cc.DelayTime:create(0.3),
        cc.CallFunc:create(function ()
            while self:checkAndExplode() do end 
        end),
        cc.CallFunc:create(function ()
            self:fillNewItem()
        end)
    )
    self:runAction(action)
end

--[[
    泡泡消除检测 【行检测 then 列检测】
    isCheck == true : 检测模式 不消除
    isCheck == nil or false : 检测 并 消除
]]
function Manager:checkAndExplode(isCheck)
    local function getGridID(x, y)
        if self.gridMap[x][y] == nil then 
            return 0
        else 
            return self.gridMap[x][y].ID 
        end 
    end 
    --[[ 行检测 ]]
    for row = 1, self.RowCount do 
        local id = getGridID(row, 1)
        local startIndex = 1 
        local count = 1 
        for col = 2, self.ColCount do 
            --[[ 相同ID 往后继续检测]]
            if getGridID(row, col) > 0 and getGridID(row, col) == id then 
                count = count + 1 
                --[[ 检测完一行 ]]
                if col == self.ColCount and count >= 3 then 
                    --[[ 检测模式： 不消除 ]]
                    if isCheck ~= nil and isCheck == true then 
                        return true 
                    end 
                    --[[ 标记可消除的泡泡 ]]
                    for j = startIndex, startIndex + count - 1 do 
                        table.insert(self.explodeList, self.gridMap[row][j])
                        self.gridMap[row][j] = nil 
                    end 
                    self:explodeBubble()
                    return true 
                end 
            else --[[ ID 不同 ]]
                if count >= 3 then 
                    if isCheck ~= nil and isCheck == true then 
                        return true 
                    end 
                    for j = startIndex, startIndex + count - 1 do 
                        table.insert(self.explodeList, self.gridMap[row][j])
                        self.gridMap[row][j] = nil 
                    end 
                    self:explodeBubble()
                    return true 
                else 
                    id = getGridID(row, col) 
                    count = 1 
                    startIndex = col 
                end 
            end 
        end 
    end 

    --[[ 列检测 ]]
    for col = 1, self.ColCount do
        local id = getGridID(1, col) 
        local startIndex = 1 
        local count = 1 
        for row = 2, self.RowCount do 
            if getGridID(row, col) > 0 and getGridID(row, col) == id then 
                count = count + 1 
                if row == self.RowCount and count >= 3 then 
                    if isCheck ~= nil and isCheck == true then 
                        return true 
                    end 
                    for i = startIndex, startIndex + count - 1 do
                        table.insert(self.explodeList, self.gridMap[i][col])
                        self.gridMap[i][col] = nil 
                    end 
                    self:explodeBubble()
                    return true 
                end 
            else             
                if count >= 3 then 
                    if isCheck ~= nil and isCheck == true then 
                        return true 
                    else 
                        for i = startIndex, startIndex + count - 1 do 
                            table.insert(self.explodeList, self.gridMap[i][col])
                            self.gridMap[i][col] = nil 
                        end 
                        self:explodeBubble()
                        return true 
                    end 
                else 
                    id = getGridID(row, col) 
                    startIndex = row 
                    count = 1
                end 
            end 
        end 
    end

    return false 
end

--[[
    checkAndExplode 标记的泡泡进行消除
]]
function Manager:explodeBubble()
    if #self.explodeList < 1 then 
        return 
    end 

    for i = 1, #self.explodeList do
        cclog(self.explodeList[i].posX, self.explodeList[i].posY)
    end

    self.score = self.score + #self.explodeList
    self.scoreLabel:setString(self.score)

    for i = 1, #self.explodeList do
        local explodeParticle = cc.ParticleSystemQuad:create("bubbleEXplode.plist")
        local posX, posY = self.explodeList[i]:getPosition()
        explodeParticle:pos(posX, posY):addTo(explodeParticle, 6)
            :setAutoRemoveOnFinish(true)

        local x, y = self.explodeList[i].posX, self.explodeList[i].posY
        -- self.gridMap[x][y] = nil 
        self.explodeList[i]:pos(1, 3000) -- "消除当前对象" -- 移走
    end
end

--[[
    填充空缺的泡泡
    每列自上向下移动
]]
function Manager:fillNewItem()
cclog("fill")
    local explodeListIndex = 1 -- 用待销毁队列中的对象重新填充
    for col = 1, self.ColCount do
        for row = 1, self.RowCount do
            if self.gridMap[row][col] == nil then 
                local ok = false 
                for i = row + 1, self.RowCount do
                    local bubble = self.gridMap[i][col]
                    if bubble ~= nil then 
                        self.gridMap[i][col] = nil 
                        self.gridMap[row][col] = bubble
                        bubble:moveToGrid(row, col) 
                        bubble.posX = row
                        bubble.posY = col 

                        ok = true 
                        break 
                    end 
                end
                if ok == false then 
                    local bubble = self.explodeList[explodeListIndex]
                    explodeListIndex = explodeListIndex + 1
                    -- 不重新创建Sprite，从explodeList中获取。
                    -- 但是资源（图片）重新加载
                    -- [[ 这里是UI坐标，x，y不同于二维数组gridMap ；此处需要从界面外进行向下掉落 ]]
                    local stX = self.startPos.x + self.bubbleLen * (col - 1) 
                    local stY = self.startPos.y + self.bubbleLen * (self.RowCount + 3)
                    bubble:pos(stX, stY):setInfo(math.random(1, 5))
                    bubble:moveToGrid(row, col) 
                    bubble.posX = row 
                    bubble.posY = col 
                    self.gridMap[row][col] = bubble
                end 
            end 
        end
    end

    self.explodeList = {}

    self:fillNext() -- 递归消除
end

--[[
    填充完之后，再次检测
    递归：checkAndExplode() fillNewItem() fillNewItem()
        入口：fillNewItem()
        出口：fillNext()
]]
function Manager:fillNext()
    local action = cc.Sequence:create(cc.DelayTime:create(0.3),
        cc.CallFunc:create(function ()
            local haveLine = false 
            while self:checkAndExplode() do 
                haveLine = true 
            end 

            if haveLine == false then 
                self.isCanTouch = true 
                return 
            end 
            
            self:fillNewItem()
        end)
    )
    self:runAction(action)
end

return Manager 