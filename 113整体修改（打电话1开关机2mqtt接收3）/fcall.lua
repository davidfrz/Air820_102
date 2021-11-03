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



--订阅消息的用户回调函数
--sys.subscribe("CALL_READY",ready)
-- sys.subscribe("NET_STATE_REGISTERED",ready)




