--- 模块功能：针对矩阵按键的任务分配
-- @module ftask
-- @author 范润泽
-- @license MIT
-- @copyright 范润泽
-- @release 2021.09.03

module(...,package.seeall)

require "faudio"
require "fhttp"

local locStr=""

-- locStr = fhttp.returnLoc()

local function ftask_thread()
    while true do
        local result,data = sys.waitUntil("key")

        if result then
            if data == "task_1" then
                log.info("按键", "第1个按键按下")
                faudio.test_01("第一个按键")
            elseif data == "task_2" then
                log.info("按键", "第2个按键按下")
                -- faudio.test_01("第二个按键")
                -- locStr = tostring(fhttp.getLoc())
                locStr = tostring(fhttp.returnLocation())
                faudio.test_01("您现在位于"..locStr)
            elseif data == "task_3" then
                log.info("按键", "第3个按键按下")
                faudio.test_01("第三个按键")
            elseif data == "task_4" then
                log.info("按键", "第4个按键按下")
                faudio.test_01("第四个按键")
            elseif data == "task_5" then
                log.info("按键", "按键被按下")
            elseif data == "task_long" then
                log.info("按键", "按键被长按")
                faudio.test_01("长按操作")
            end
        end
    end
end

sys.taskInit(ftask_thread)