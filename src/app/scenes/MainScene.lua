---@diagnostic disable: lowercase-global

local function createStartBackLayer()
    local backLayer = createCommonBackLayer()
    -- logo
    local spriteLogo = createAtlasSprite("title")
    spriteLogo:setPosition(cc.p(visibleSize.width / 2, visibleSize.height * 2 / 3))
    backLayer:addChild(spriteLogo)

    -- flappy bird
    local spriteBird = createBird()
    spriteBird:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 + 25))
    spriteBird:runAction(createFlyAction(cc.p(spriteBird:getPosition())))
    backLayer:addChild(spriteBird)

    -- rate button
    local rateButton = createAtlasSprite("button_rate")
    rateButton:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 - 35))
    backLayer:addChild(rateButton)

    -- play button
    local playButton = createAtlasSprite("button_play")
    playButton:setPosition(cc.p(visibleSize.width / 4, visibleSize.height / 2 - 120))
    backLayer:addChild(playButton, 1000)

    -- rank button
    local rankButton = createAtlasSprite("button_score")
    rankButton:setPosition(cc.p(visibleSize.width * 3 / 4, visibleSize.height / 2 - 120))
    backLayer:addChild(rankButton, 1000)

    -- copy right
    local spriteCopyright = createAtlasSprite("brand_copyright")
    spriteCopyright:setPosition(cc.p(visibleSize.width / 2, visibleSize.height / 2 - 170))
    backLayer:addChild(spriteCopyright, 1000)	

    -- for common listener
    g_rateButton = rateButton
    g_playButton = playButton
    g_rankButton = rankButton

    local listener = cc.EventListenerTouchOneByOne:create()
    listener:registerScriptHandler(onCommonMenuLayerTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    listener:registerScriptHandler(onCommonMenuLayerTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    local eventDispatcher = backLayer:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, backLayer)

    return backLayer
end

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

a = require("app.out") 
-- require("src.app.scripts.tools")

local function createAtlasSprite(name)
    local tmpTable = a[name]
    
    local rectX = tmpTable.x
    local rectY = tmpTable.y
    local rectWidth = tmpTable.width
    local rectHeight = tmpTable.height

    -- fix 1px edge bug
    if name == "land" then
        rectX = rectX + 1            
    end

    local rect = cc.rect(rectX, rectY, rectWidth, rectHeight)
    local frame = cc.SpriteFrame:createWithTexture(textureAtlas, rect)
    local atlasSprite = cc.Sprite:createWithSpriteFrame(frame)

    return atlasSprite
end

local function Action(self) 
    local png = display.newSprite("image/atlas.png"):addTo(self):center():scale(0.3)
    png:setPositionX(100)
    -- png:runAction(cc.MoveTo:create(2, cc.p(display.width - 100, display.cy)))
    -- png:runAction(cc.MoveBy:create(2, cc.p(500, 0)))

    --[[
    local move1 = cc.MoveTo:create(2, cc.p(display.width - 100, display.cy))
    local move2 = cc.MoveBy:create(2, cc.p(-500, 0))
    png:runAction(cc.Sequence:create(move1, move2))
    ]]--

    --[[
    local move1 = cc.MoveBy:create(2, cc.p(500, 0))
    local move2 = move1:reverse()
    png:runAction(cc.Sequence:create(move1, move2))
    ]]-- 

    --[[
        local move = cc.MoveBy:create(2, cc.p(500, 0))
        local scale = cc.ScaleTo:create(2, 1) 
        png:runAction(cc.Spawn:create(move, scale))
    ]]--

    local move = cc.MoveBy:create(1, cc.p(450, 0))
    local scale = cc.ScaleTo:create(1, 0.1)  -- 时间，系数
    -- png:runAction(cc.Spawn:create(move, scale))
    png:runAction(cc.Sequence:create(
        cc.Spawn:create(move, scale),
        cc.CallFunc:create(function()
            cclog("over!!!")
        end)
    ))
    local bird = createAtlasSprite("bird0_1")
        :addTo(self):pos(display.cx - 250, display.cy)
    -- JumpTo: （时间，位置，高度，次数） 跳
    -- RotateTo 
    -- FateIn, FateOut 
    -- Blink 
    -- Animation: 序列帧动画 = 逐帧动画
    local bird_action1 = cc.JumpTo:create(1, cc.p(display.width - bird:getPositionX(), display.cy), 40, 2)
    local bird_action2 = cc.RotateBy:create(1, 360)
    bird:runAction(cc.Spawn:create(bird_action1, bird_action2))
end 

local function teXiao( self )
    local role = cc.NodeGrid:create()
    role:addChild(display.newSprite("image/atlas.png")):center():addTo(self):scale(0.2)
    -- role:runAction(cc.Shaky3D:create(10, cc.size(50, 50), 5, false))
    -- role:runAction(cc.ShakyTiles3D:create(10, cc.size(50, 50), 5, false))
    -- role:runAction(cc.ShuffleTiles:create(1, cc.size(50, 50), 5))
    -- role:runAction(cc.TurnOffTiles:create(1, cc.size(50, 50))) 
    
    local w1 = role:runAction(cc.Waves3D:create(2, cc.size(15, 10), 5, 40)) 
    local w2 = role:runAction(cc.Waves3D:create(1, cc.size(15, 10), 0, 0)) 
    local removeAction = cc.RemoveSelf:create() -- 做完特效后 删除自身
    local callback = cc.CallFunc:create(function ()
        cclog("action over~") 
    end)
    role:runAction(cc.Sequence:create(w1, w2, removeAction, callback))
end

local function sceneTrans( self )
    textureAtlas = cc.Director:getInstance():getTextureCache():addImage("image/atlas.png")

    local back1 = createAtlasSprite("bg_day")
    back1:addTo(self):center()

    local schedule = self:getScheduler() 
    local s
    s = schedule:scheduleScriptFunc(function ( f )
        schedule:unscheduleScriptEntry(s)
        
        local Scene = cc.Scene:create() 
        local back2 = createAtlasSprite("bg_night") -- 放外面捕获不到！
        back2:addTo(Scene):center()

        -- cc.Director:getInstance():replaceScene(Scene)

        --[[
        local transition = cc.TransitionCrossFade:create(1, Scene)
        cc.Director:getInstance():replaceScene(transition)
        ]]-- 
        --[[
        local transition = cc.TransitionZoomFlipAngular:create(1, Scene)
        cc.Director:getInstance():replaceScene(transition)
        ]]-- 
        --[[
        local transition = cc.TransitionPageTurn:create(1, Scene, true) -- true, false 盖住，翻出
        cc.Director:getInstance():replaceScene(transition)
        ]]-- 
        --[[
        local transition = cc.TransitionProgressRadialCW:create(1, Scene) 
        cc.Director:getInstance():replaceScene(transition)
        ]]-- 
        local transition = cc.TransitionSplitRows:create(1, Scene) 
        cc.Director:getInstance():replaceScene(transition)

    end, 2, false) -- false: 立即执行

end

local function addButton(self)
    -- (普通，按下，禁用，0/1（文件/精灵帧缓存）)
    local playBtn = ccui.Button:create("image/button.png", "image/button.png", "image/button.png", 0)
        :pos(display.width - 20, display.cy):addTo(self):scale(0.2)
    playBtn:setTitleText("Button"):setTitleFontSize(55):setTitleColor(cc.c3b(40, 44, 52)):setTitleOffset(0, 90)
    playBtn:addTouchEventListener(function(sender, eventType) -- obj, type 
        if 0 == eventType then 
            print("pressed")
        elseif 1 == eventType then 
            print("move") 
        elseif 2 == eventType then 
            print("up") 
        elseif 3 == eventType then
            print("cancel")
        end
    end)
    -- playBtn:setEnabled(false) -- 禁用
    
    -- 文本按钮
    local textBtn = ccui.Button:create()
        :setTitleText("Text Button"):setTitleFontSize(50)
        :addTo(self):pos(display.cx, display.cy - 50)

    -- CheckBox 
    local checkBtn = ccui.CheckBox:create("image/button.png","image/button.png","image/button.png","image/button.png","image/button.png")
        :addTo(self):setVisible(false)
end

local function rotation(self)
    --[[ -- 点和矩形旋转
    local rect = display.newDrawNode():addTo(self):center()
        :drawRect(cc.p(0, 0), cc.p(300, 300), cc.c4f(1.0, 0, 0, 1.0))
    local dot = display.newDrawNode():addTo(rect):pos(20, 20)
        :drawDot(cc.p(0, 0), 10, cc.c4b(1.0, 1.0, 1.0, 1.0)) 

    rect:size(300, 300):setAnchorPoint(cc.p(0.5, 0.5)) 

    self:getScheduler():scheduleScriptFunc(function(f)
        rect:rotation(rect:getRotation() + 1)
        local p = dot:convertToWorldSpace(cc.p(0, 0))
        print("%f %f", p.x, p.y)
    end, 0, false)
    ]]-- 

    --[[ -- 绘制小球椭圆
    local angle = 0 
    local dot = display.newDrawNode():addTo(self):center()
        :drawDot(cc.p(0, 0), 10, cc.c4b(1.0, 1.0, 1.0, 1.0)) 
    
    
    self:getScheduler():scheduleScriptFunc(function(f)
        dot:setPositionX(display.cx + math.sin(angle) * 150)
        dot:setPositionY(display.cy + math.cos(angle) * 100)
        angle = angle + 0.1 
    end, 0, false) 
    ]]--  

    --[[ -- 反弹的小球 
    local direction = cc.p(math.random(-1, 1), math.random(-1, 1)) 
    cc.pNormalize(direction) 

    local dot = display.newDrawNode():addTo(self):center()
        :drawDot(cc.p(0, 0), 10, cc.c4b(1.0, 1.0, 1.0, 1.0)) 
    self:getScheduler():scheduleScriptFunc(function(f)
        local px, py = dot:getPosition() 

        if px < 0 or px > display.width then 
            direction.x = direction.x * -1 
        end 
        if py < 0 or py > display.height then 
            direction.y = direction.y * -1 
        end 
        dot:pos(px + direction.x * 10, py + direction.y * 10)
    end, 0, false) 
    ]]-- 
end

local function musicPlay(self)  
    local preloadMusic = ccui.Button:create() 
        :addTo(self):pos(display.cx + 150, display.cy - 150)
        :setTitleText("preloadMusic oggs"):setTitleFontSize(40)
        :setTitleColor(cc.c3b(255, 0, 0))
    
    local playMusic = ccui.Button:create()
        :addTo(self):pos(display.cx + 150, display.cy - 150)
        :setTitleText("playMusic oggs"):setTitleFontSize(40)
        :setTitleColor(cc.c3b(255, 0, 0))
        :setVisible(false) 

    playMusic:addTouchEventListener(function (sender, eventType)
        if 2 == eventType then 
            self._effect = audio.playEffect("wav/sfx_hit.ogg", false) -- boolean: 循环播放 
            if self._effect then 
                cclog("play success") 
                self._effect:setVolume(0.5) 
                self:performWithDelay(function ()
                    self._effect:stop()
                    self._effect = nil 
                    -- ok = audio.unloadFile("wav/sfx_hit.ogg")
                    audio.unloadAllFile()
                end, 2)
            end 
        end 
    end)

    preloadMusic:addTouchEventListener(function (sender, eventType) 
        if 2 == eventType then 
            audio.loadFile("wav/sfx_hit.ogg", true) 
            preloadMusic:setVisible(false)
            playMusic:setVisible(true)  
        end 
    end)
end

local function mySchedule(self)
    -- 全局帧调度器
    -- 全局自定义调度器
    local scheduler = self:getScheduler()
    -- 节点调度器
end

local function myEvent(self) 
    -- start 
    -- 节点事件
    local sprite = cc.Sprite:createWithSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame("BEATTACKFALL0012.png"))
        :addTo(self):pos(200, 200) 
    -- 节点事件在一个Node对象进入和退出场景时触发
    sprite:addNodeEventListener(cc.NODE_EVENT, function (event)
        cclog(event.name)
    end)
    sprite:setNodeEventEnabled(true) 

    -- 帧事件
    local node = display.newNode():addTo(self)
    node:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function (dt)
        print(dt) 
    end)
    node:scheduleUpdate() -- 启用帧事件

    node:performWithDelay(function ()
        node:unscheduleUpdate() -- 禁用帧事件
        cclog("stop") 

        -- node:performWithDelay(function ()
        --     node:scheduleUpdate()
        -- end, 1)
    end, 1) 

    -- 键盘事件
    self:setKeypadEnabled(true)
    self:addNodeEventListener(cc.KEYPAD_EVENT, function (event)
        cclog(event.code .. event.key .. event.type)
    end)
    -- 加速器事件
    -- 触摸事件
        -- 1. 单点
    sprite:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
        cclog(event.name .. "(" .. event.x .. ", " .. event.y .. ")")
        if event.name == "began" then return true end 
        -- began返回true表示要响应触摸，阻止事件传递给父对象
        -- Node:setTouchSwallowEnabled() 默认true，吞噬事件，false，仍会传递事件给父节点
    end)
    sprite:setTouchMode(cc.TOUCH_MODE_ONE_BY_ONE)
    sprite:setTouchEnabled(true) 
        -- 2. 多点
    -- TOUCH_MODE_ALL_AT_ONCE
end

local function saveData(self) 
    cc.UserDefault:getInstance():setIntegerForKey("score", 100) 
    local data = cc.UserDefault:getInstance():getIntegerForKey("score")
    cclog(data) 

    cc.UserDefault:getInstance():setStringForKey("data", json.encode("{'name': cauchy, 'score': 100}")) 
    local data = cc.UserDefault:getInstance():getStringForKey("data")
    local decode = json.decode(data)
    cclog(decode) 
end

local function myVector(self)
    -- 滚动容器
    local pageView = ccui.PageView:create() 
    pageView:setContentSize(600, 600) 
    pageView:setTouchEnabled(true) 
    pageView:setAnchorPoint(cc.p(0.5, 0.5)) 
        :setPosition(display.cx, display.cy) 
        :addTo(self)
    for i = 1, 5 do 
        local layout = ccui.Layout:create():addTo(pageView)
            :setContentSize(600, 600) 
            :setPosition(0, 0) 
        local img = string.format("BEATTACKFALL00%02d.png", i) 
        local sprite = cc.Sprite:createWithSpriteFrame(cc.SpriteFrameCache:getInstance():getSpriteFrame(img))
        -- local btn = ccui.Button:create(sprite)
            :setPosition(300, 300) 
            :addTo(layout)
    end 
    function MainScene:onEvent(sender, event)
        cclog("111")
    end
    pageView:addEventListener(handler(self, self.onEvent)) 
    
end

function showObj(self)    
    -- 显示对象： 预加载
    local img = cc.Director:getInstance():getTextureCache():addImage("image/button.png")

    local imgsz = img:getContentSize() 
    print("logo size : ", imgsz.width, imgsz.height)
    
    local logo = display.newSprite(img):addTo(self):center() 
end

function virualHandle(self)
    local v = require("src.app.VirtualHandle").new() 
    self:addChild(v) 
    v:setPositionY(display.height / 3)  -- 设置摇杆的图层的Y方向高度

    v:setCallBack(function (...)
        print(...)
    end)
end

function MainScene:ctor()
    display.newTTFLabel({
            text = "Cocos Project", 
            size = 64,
            font = "fonts/Marker Felt.ttf",
            color = cc.c3b(255, 255, 0),
            dimensions = cc.size(0, 0)
        })
        :align(display.CENTER, display.cx, display.cy)
        :addTo(self)
    textureAtlas = cc.Director:getInstance():getTextureCache():addImage("image/atlas.png")

    require("app.scripts.loadTexture")
    loadAllTexture()
    local actions = laoyingAnimations("beattackfly")
    actionsImpl(self, actions, display.cx - 150, display.cy - 150)

    -- Action(self)
    -- teXiao(self)
    -- sceneTrans(self) 
    -- addButton(self)
    -- rotation(self)
    -- showObj(self) 
    -- virualHandle(self)
    -- musicPlay(self) 
    -- mySchedule(self)
    -- myEvent(self) 
    -- saveData(self) 
    -- myVector(self) 
    cclog(cc.touch:getLocation())

    -- local backLayer = createStartBackLayer()
    -- backLayer:addTo(self)

    -- releaseCaches() -- loadTexture 文件的功能
end

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene
