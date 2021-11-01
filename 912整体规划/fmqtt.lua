--[[
Author: 范润泽
Date: 2021-09-02 13:10:40
LastEditTime: 2021-09-02 13:10:40
LastEditors: 范润泽
Description: In User Settings Edit
--]]

require "mqtt"
require "sys"
require "fgps"
require "ftask"

module(...,package.seeall)

-- local host = "47.107.166.30"
-- local port = 1883
-- local user = "test1"
-- local pwd = "550025"
-- local id = "Air820"
-- local keepAlive = 300
-- local pubtopic = "air820"

local host = "47.107.166.30"
local port = 1883
local user = "test1"
local pwd = "550025"
local id = "Air820"
local keepAlive = 300
local pubtopic = "air820"



---函数功能：
-- 对mqtt进行初始化
-- @param 
-- @retrun  
-- @example:  直接调用
function mqttInit()
    while not socket.isReady() do
        log.info("网络没有连接好", "一秒钟后重新连接")
        sys.wait(1000) end
    local mqttc = mqtt.client(id, keepAlive, user, pwd)
    log.info("mqtt正在连接", "yes")

    local mqttstatus = mqttc:connect(host, port, "tcp")
    while not mqttstatus do
        log.info("mqtt connect", "mqtt连接错误")
        sys.wait(1000)
    end
end

---函数功能：
-- mqtt上传消息
-- @param
-- @retrun
-- @example  直接调用
function pubMqtt()
    sys.wait(3000)
    transBlng = fgps.returnBlng()
    transBlat = fgps.returnBlat()
    data = transBlng.."+"..transBlat

    local pubstatus = mqttc:publish(pubtopic, data, 0)
    if pubstatus then
        log.info("pubstatus", "上传成功")
    else
        log.info("pubstatus", "上传失败")
    end
end

sys.taskInit(function()
    
    while not socket.isReady() do
        log.info("网络没有连接好", "一秒钟后重新连接")
        sys.wait(1000) end
    local mqttc = mqtt.client(id, keepAlive, user, pwd)
    log.info("mqtt正在连接", "yes")

    local mqttstatus = mqttc:connect(host, port, "tcp")
    while not mqttstatus do
        log.info("mqtt connect", "mqtt连接错误")
        sys.wait(1000)
    end
    
    while true do
        sys.wait(3000)
        transBlng = fgps.returnBlng()
        transBlat = fgps.returnBlat()
        data = transBlng.."+"..transBlat
        local workMode = ftask.ReWm()
    
        if workMode then
            local pubstatus = mqttc:publish(pubtopic, data, 0)
            if pubstatus then
                log.info("pubstatus", "上传成功")
            else
                log.info("pubstatus", "上传失败")
            end
            sys.wait(5000)
        end
        
    end

    mqttc:disconnect()
end)