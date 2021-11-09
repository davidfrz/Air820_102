--- 模块功能：通话功能测试.
-- @author openLuat
-- @module call.testCall
-- @license MIT
-- @copyright openLuat
-- @release 2018.03.20

module(...,package.seeall)
require"cc"

--- “通话功能模块准备就绪””消息处理函数
-- @return 无
function ready(num)
    log.info("tesCall.ready")
    --呼叫10086
    -- sys.timerStart(cc.dial,10000,"15613323375")
    cc.dial(num,3500)
end

--- “通话功能模块准备就绪””消息处理函数
-- @return 无
function status()
    log.info("查询号码状态")
    --呼叫10086
    -- sys.timerStart(cc.dial,10000,"15613323375")
    state = cc.getState('15613323375')
    log.info("phone_status", state)
end

local function incoming(num)
    log.info("testCall.incoming:"..num)
    
    if not coIncoming then
        coIncoming = sys.taskInit(function()
            while true do
                audio.play(1,"TTS","来电话啦",4,function() sys.publish("PLAY_INCOMING_RING_IND") end,true)
                -- audio.play(1,"FILE","call.mp3",4,function() sys.publish("PLAY_INCOMING_RING_IND") end,true)
                sys.waitUntil("PLAY_INCOMING_RING_IND")
                break                
            end
        end)
        sys.subscribe("3_KEY_IND",function() audio.stop(function() cc.accept(num) end) end)
    end
    
    --[[
    if not coIncoming then
        coIncoming = sys.taskInit(function()
            for i=1,7 do
                --audio.play(1,"TTS","来电话啦",i,function() sys.publish("PLAY_INCOMING_RING_IND") end)
                audio.play(1,"FILE","/lua/call.mp3",i,function() sys.publish("PLAY_INCOMING_RING_IND") end)
                sys.waitUntil("PLAY_INCOMING_RING_IND")
            end
            --接听来电
            --cc.accept(num)
        end)
        
    end]]
    --接听来电
    --cc.accept(num)
    
    
end


--订阅消息的用户回调函数
--sys.subscribe("CALL_READY",ready)
-- sys.subscribe("NET_STATE_REGISTERED",ready)
sys.subscribe("CALL_INCOMING",incoming)




