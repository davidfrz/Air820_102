--- 模块功能：针对矩阵按键的任务分配
-- @module ftask
-- @author 范润泽
-- @license MIT
-- @copyright 范润泽
-- @release 2021.09.03

module(...,package.seeall)

require "faudio"
require "fhttp"
require "fcall"
require "fmqtt"

local locStr=""
_G.wm = false
-- locStr = fhttp.returnLoc()



local function ftask_thread()
    while true do
        local result,data = sys.waitUntil("key")

        if result then
            if data == "task_1" then
                faudio.test_01("第一个按键")
            elseif data == "task_2" then
                log.info("按键", "第2个按键按下")
                if wm then
                    locStr = fhttp.returnLocation()
                    locStr = tostring(locStr)
                    faudio.test_01("您现在位于"..locStr) 
                    
                else
                    faudio.test_01("请打开监控模式获取定位信息") 
                end
                
            elseif data == "task_3" then
                log.info("按键", "第3个按键按下")
                -- faudio.test_01("第三个按键")
                if wm then
                    ph_num=fmqtt.re_phone_num()
                    log.info("电话号码", ph_num)
                    faudio.test_01("拨打"..ph_num)
                    fcall.ready(ph_num)
                    -- fcall.status()
                    
                else
                    faudio.test_01("请打开监控模式拨打电话") 
                end
            elseif data == "task_4" then
                log.info("按键", "第4个按键按下")
                faudio.test_01("第四个按键")
                -- rtos.poweroff()
            elseif data == "task_5" then
                log.info("按键", "按键被按下")
            elseif data == "task_long" then
                log.info("按键", "按键被长按")
                -- faudio.test_01("长按操作")
                if not wm then
                    log.info("按键", "第1个按键按下")
                    faudio.test_01("进入监控模式")
                    wm = not wm
                else
                    faudio.test_01("进入空闲模式")
                    wm = not wm
                end
            end
        end
    end
end

function ReWm()
    return wm
end

sys.taskInit(ftask_thread)