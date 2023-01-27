---@diagnostic disable: lowercase-global
local function loadOneTexture(plist, png)
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plist, png) -- plist数据文件, image纹理文件，handler回调函数
end

function loadAllTexture()
    local plist, png = "image/laoying.plist", "image/laoying.png"
    loadOneTexture(plist, png)
end

local function getAnimation(picPrefix, time) 
    local frameCount = 0 
    local frames = {} 
    while true do 
        local key = string.format("%s%02d.png", picPrefix, frameCount + 1) 
        local spframe = cc.SpriteFrameCache:getInstance():getSpriteFrame(key)  -- 通过key拿到frame
        -- local sp = cc.Sprite:createWithSpriteFrames(spframe) -- 进入frame取Sprite （有方法：getTextureRect, registerScriptHandler）
        if spframe == nil then break end 
        frameCount = frameCount + 1 
        frames[frameCount] = spframe 
    end 
    if #frames < 1 then return end
    local animation = cc.Animation:createWithSpriteFrames(frames, time / frameCount)
    return animation
end

function actionsImpl(obj, actions, posX, posY)
    local sp = cc.Sprite:create()
        :addTo(obj):stopAllActions():pos(posX or display.cx, posY or display.cy)
    sp:runAction(cc.Sequence:create(actions))
end

function releaseCaches()
    -- 先清理动画缓存，然后清理精灵帧缓存，最后是纹理缓存
    -- 按照引用层级由高到低，以保证释放引用有效。
    cc.AnimationCache:destroyInstance() 
    cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
    cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function laoyingAnimations(actionName)
    local actions = {} 
    local prefix = nil 
    if actionName == "attack" then 
        prefix = "ATTACK000" 
    elseif actionName == "beattack" then 
        prefix = "BEATTACK00"
    elseif actionName == "beattackall" then 
        prefix = "BEATTACKFALL00"
    elseif actionName == "beattackfly" then 
        prefix = "BEATTACKFLY00"
    elseif actionName == "idle" then 
        prefix = "IDLE00"
    elseif actionName == "walk" then 
        prefix = "WALK00"
    end 
    actions[#actions+1] = cc.Animate:create(getAnimation(prefix, 1))
    actions[#actions+1] = cc.CallFunc:create(function ()
        cclog("laoying actions over")
    end) 
    actions[#actions+1] = cc.RemoveSelf:create() 
    return actions 
end