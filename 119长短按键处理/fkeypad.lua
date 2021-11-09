--- 模块功能：矩阵键盘测试
-- @module powerKey
-- @author 范润泽
-- @license MIT
-- @copyright 范润泽
-- @release 2021.09.03

require"sys"
-- require "faudio"
module(..., package.seeall)


--[[
sta：按键状态，IDLE表示空闲状态，PRESSED表示已按下状态，LONGPRESSED表示已经长按下状态
longprd：长按键判断时长，默认3秒；按下大于等于3秒再弹起判定为长按键；按下后，在3秒内弹起，判定为短按键
longcb：长按键处理函数
shortcb：短按键处理函数
]]
local sta,longprd = "IDLE",3000

local function longtimercb()
    log.info("keypad.longtimercb")
    sta = "LONGPRESSED"
end

local function longtimercb_2()
    log.info("keypad.longtimercb")
    faudio.test_01("正在关机")
    sta = "POWER_OFF"
end

local function longtimercb_3()
    log.info("keypad.longtimercb")
    sta = "CALL"
end

local function shortCb_1()
    log.info("短按操作")
    sta = "LOC"    
end

local function shortCb_2()
    log.info("短按操作")
    sta = "INC"  
end



-- 考虑一下是不是要用sys.publish(...)
local function operKey(row,col,pre)
    if pre then
        
        if row == 1 then
            if col == 0 then
                -- sys.publish("key","task_1")
                sta = "PRESSED"
                sys.publish("acq","ttsLoc")
                sys.timerStart(longtimercb,longprd)
            elseif col == 1 then
                sta="SMS"
                -- sys.publish("acq","ttsLoc")
                -- sys.publish("key","task_2")
                sys.publish("key","task_a")
                
            end
        elseif row == 2 then
            if col == 0 then
                sta = "PRE"
                -- sys.publish("key","task_b")
                sys.timerStart(longtimercb_3,longprd)
                -- sys.timerStart(longtimercb_3,5000)
                -- sys.timerStart(longtimercb_4,8000)
            -- elseif col == 0 then
            --     sys.publish("key","task_4")
                
            end
        elseif row == 255 then
            if col == 255 then
                -- sta = "PRESSED"
                sta="P"
                sys.timerStart(longtimercb_2,5000)
                -- sys.publish("key","task_4")
            end
        end
    else
        sys.timerStop(longtimercb)
        if sta=="PRESSED" then
            shortCb_1()
            sys.publish("key","task_2")
            sys.publish("acq","ttsLoc")

        elseif sta=="PRE" then
            sys.publish("3_KEY_IND")
        elseif sta=="LONGPRESSED" then
            -- rtos.poweroff()
            sys.publish("key","task_long")
        elseif sta=="POWER_OFF" then
            log.info("关机",sta);
            -- faudio.test_01("正在关机") 
            rtos.poweroff()
        elseif sta=="CALL" then
            sys.publish("key","task_3")
        -- elseif sta=="LONG2" then
        --     rtos.poweroff()
        --     -- sys.publish("key","task_long")
        --     sys.publish("acq","ttsLoc")
		end
		sta = "IDLE"

    end
end


local function keyMsg(msg)
    --msg.key_matrix_row：行
    --msg.key_matrix_col：列
    --msg.pressed：true表示按下，false表示弹起
    log.info("keyMsg",msg.key_matrix_row,msg.key_matrix_col,msg.pressed)
    operKey(msg.key_matrix_row,msg.key_matrix_col,msg.pressed)
end


--注册按键消息处理函数
rtos.on(rtos.MSG_KEYPAD,keyMsg)
--初始化键盘阵列
--第一个参数：固定为rtos.MOD_KEYPAD，表示键盘
--第二个参数：目前无意义，固定为0
--第三个参数：表示键盘阵列keyin标记，例如使用了keyin0、keyin1、keyin2、keyin3，则第三个参数为1<<0|1<<1|1<<2|1<<3 = 0x0F
--第四个参数：表示键盘阵列keyout标记，例如使用了keyout0、keyout1、keyout2、keyout3，则第四个参数为1<<0|1<<1|1<<2|1<<3 = 0x0F
rtos.init_module(rtos.MOD_KEYPAD,0,0x0F,0x0F)
