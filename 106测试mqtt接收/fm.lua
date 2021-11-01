--[[
Author: 范润泽
Date: 2021-09-02 13:10:40
LastEditTime: 2021-09-02 13:10:40
LastEditors: 范润泽
Description: In User Settings Edit
--]]

require "mqtt"
require "sys"
require "faudio"



module(...,package.seeall)

-- local host = "47.107.166.30"
-- local port = 1883
-- local user = "test1"
-- local pwd = "550025"
-- local id = "Air820"
-- local keepAlive = 300
-- local pubtopic = "air820"

local host = "38f183340u.zicp.vip"
local port = 56095
local user = "smqtt"
local pwd = "smqtt"
local id = "Air820"
local keepAlive = 30
local pubtopic = "lab102"



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

    -- local mqttstatus = mqttc:connect(host, port, "tcp")
    -- while not mqttstatus do
    --     log.info("mqtt connect", "mqtt连接错误")
    --     sys.wait(1000)
    -- end

    while not mqttc:connect(host, port, "tcp") do
        log.info("mqtt connect", "mqtt连接错误")
        sys.wait(2000)
    end
    
    
    sys.wait(3000)

    if mqttc:subscribe("lab102", 0) then
        while true do
            local r, data, param = mqttc:receive(120000, "pub_msg")
            log.info("接收", data.topic,data.payload)
            faudio.test_01(data.payload)
            sys.wait(2000)
        end
    end
    


    mqttc:disconnect()
end)