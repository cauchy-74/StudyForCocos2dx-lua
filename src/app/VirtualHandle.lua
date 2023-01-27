--[[
    1. ui控件绑定触摸事件的方法
    2. 针对全局绑定触摸事件的方法
    3. 手柄的设计
]]

local VirtualHandleEvent = {
    A = "A", 
    B = "B", 
    CANCEL_A = "CANCEL_A", 
    CANCEL_B = "CANCEL_B", 

    LEFT = "LEFT", 
    RIGHT = "RIGHT", 

    CANCEL_LEFT = "CANCEL_LEFT", 
    CANCEL_RIGHT = "CANCEL_RIGHT"
}

local VirtualHandle = class("VirtualHandle", function ()
    return display.newLayer("VirtualHandle")
end)

local rockerRangeValue = 200 -- 摇杆区域大小值
local rockerRange = nil -- 摇杆区域 
local rocker = nil -- 摇杆 
local a = nil -- A 按钮
local b = nil -- B 按钮

local rockerTouchID = -1 -- 触摸ID
local rockerWay = 0 -- 方向： 0:不动；1:向左；2:向右
local rockerLastPoint = 0 -- 记录上一次位置，用于判断方向

local _callback
local function callback(event)
    if _callback ~= nil then 
        _callback(event)
    end 
end

-- 触摸事件（addTouchEventListener） 监听的回调函数
--[[
addTouchEventListener( CC_CALLBACK_2( MyLayer::touchEvent , this ));
void touchEvent(cocos2d::Ref* pSender, cocos2d::ui::Widget::TouchEventType type);
]]--
local function touchEvent(obj, type) 
    if type == ccui.TouchEventType.began then 
        if obj == a then 
            callback(VirtualHandleEvent.A)
        elseif obj == b then 
            callback(VirtualHandleEvent.B)
        end 
    elseif type == ccui.TouchEventType.ended then 
        if obj == a then 
            callback(VirtualHandleEvent.CANCEL_A)
        elseif obj == b then 
            callback(VirtualHandleEvent.CANCEL_B)
        end 
    elseif type == ccui.TouchEventType.canceled then 
        if obj == a then 
            callback(VirtualHandleEvent.CANCEL_A)
        elseif obj == b then 
            callback(VirtualHandleEvent.CANCEL_B)
        end 
    end 
end

-- 对外的 public method 
function VirtualHandle:setCallBack(callback) 
    _callback = callback
end

-- 刷新当前位置
local function updateRockerPos(position)
    local value = rockerRange:convertToNodeSpace(position).x 

    if value < 50 then value = 50 end 
    if value > rockerRangeValue - 50 then value = rockerRangeValue - 50 end 

    rocker:stopAllActions() 
    rocker:runAction(cc.MoveTo:create(0.1, cc.p(value, rocker:getPositionY())))
end

-- 取消当前的方向，即需要输出cancel事件
local function cancelWay()
    if rockerWay == 1 then 
        callback(VirtualHandleEvent.CANCEL_LEFT)
    elseif rockerWay == 1 then 
        callback(VirtualHandleEvent.CANCEL_RIGHT)
    end 

    rockerWay = 0 
end

-- 虚拟手柄
function VirtualHandle:ctor()
    local size = display.size 

    rockerRange = ccui.Widget:create() 
    rocker = ccui.Button:create("image/button.png"):scale(0.2)
    a = ccui.Button:create("image/button.png"):scale(0.2)
    b = ccui.Button:create("image/button.png"):scale(0.2)

    local img_width = a:getContentSize().width * 0.2
    local img_height = a:getContentSize().height * 0.2 

    --#region （长度、高度（摇杆内容的高度））
    rockerRange:setContentSize(cc.size(rockerRangeValue, rocker:getContentSize().height)) 
        :setPosition(cc.p(rockerRangeValue / 2.0, 0))
    a:setPosition(cc.p(size.width -  img_width * 2, 0)) 
    b:setPosition(cc.p(size.width -  img_width * 4 - 10, 0)) 
    
    rocker:setPosition(cc.p(rockerRangeValue / 2.0, rocker:getContentSize().height / 2.0))
        :setTouchEnabled(false) -- 取消触摸事件（点击摇杆区域内都可，而不只是摇杆）
    
    rockerRange:addChild(rocker) 

    self:addChild(rockerRange) 
    self:addChild(a)
    self:addChild(b)

    a:addTouchEventListener(touchEvent) 
    b:addTouchEventListener(touchEvent)

    -- 事件分发器
    local event = cc.Director:getInstance():getEventDispatcher() 
    -- 事件触发类型
    local rockerRangeEvent = cc.EventListenerTouchOneByOne:create()
    -- 事件分发器:addEventListenerWithSceneGraphPriority(事件触发类型，感兴趣区域ccui.Widget)

    -- begin
    rockerRangeEvent:registerScriptHandler(function (touch, e)
        
        local bound = rockerRange:getBoundingBox() 
        local newP = rockerRange:convertToWorldSpace(cc.p(0, 0)) 
        bound.x = newP.x 
        bound.y = newP.y 

        local point = touch:getLocation() 

        if cc.rectContainsPoint(bound, point) then 
            rockerTouchID = touch:getId() 
            rockerLastPoint = point.x 

            if math.abs(math.abs(point.x - bound.x) - rockerRangeValue / 2) < 20 then 
                -- 原地不动
            elseif point.x - bound.x > rockerRangeValue / 2 then 
                -- 右
                rockerWay = 2
                callback(VirtualHandleEvent.RIGHT)
            else 
                -- 左
                rockerWay = 1 
                callback(VirtualHandleEvent.LEFT)
            end 

            updateRockerPos(point) 

            return true 
        end 

        return false 
    end, cc.Handler.EVENT_TOUCH_BEGAN)

    -- move
    rockerRangeEvent:registerScriptHandler(function (touch, e)
        local point = touch:getLocation()
        -- -1: 当前还未点击触发摇杆工作
        -- ~=: 当前是另一个触摸点（另一个手指的意思） 【0: p1；1:p2】
        if rockerTouchID == -1 or rockerTouchID ~= touch:getId() then 
            return -- 过滤掉
        end 

        if math.abs(rockerLastPoint - point.x) < 20 then 
            return 
        end 

        if point.x > rockerLastPoint and rockerWay ~= 2 then 
            cancelWay() 
            callback(VirtualHandleEvent.RIGHT)
            rockerWay = 2 
        elseif point.x < rockerLastPoint and rockerWay ~= 1 then 
            cancelWay() 
            callback(VirtualHandleEvent.LEFT)
            rockerWay = 1
        end 
        rockerLastPoint = point.x 
        updateRockerPos(point)

    end, cc.Handler.EVENT_TOUCH_MOVED)

    -- end 
    rockerRangeEvent:registerScriptHandler(function (touch, e)
        if rockerTouchID == -1 or rockerTouchID ~= touch:getId() then 
            return 
        end 

        cancelWay() 
        rockerTouchID = -1 
        rockerLastPoint = 0 
        updateRockerPos(cc.p(rockerRangeValue / 2, 0))

    end, cc.Handler.EVENT_TOUCH_ENDED)

    -- cancel
    rockerRangeEvent:registerScriptHandler(function (touch, e)
        if rockerTouchID == -1 or rockerTouchID ~= touch:getId() then 
            return 
        end 

        cancelWay() 
        rockerTouchID = -1 
        rockerLastPoint = 0 
        updateRockerPos(cc.p(rockerRangeValue / 2, 0))

    end, cc.Handler.EVENT_TOUCH_CANCELLED)

    event:addEventListenerWithSceneGraphPriority(rockerRangeEvent, rockerRange)
end

return VirtualHandle 