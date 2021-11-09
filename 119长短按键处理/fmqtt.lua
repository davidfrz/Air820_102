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
require "string"

module(...,package.seeall)

-- local host = "47.107.166.30"
-- local port = 1883
-- local user = "test1"
-- local pwd = "550025"
-- local id = "Air820"
-- local keepAlive = 300
-- local pubtopic = "air820"

-- local host = "47.107.166.30"
-- local port = 1883
-- local user = "test1"
-- local pwd = "550025"
-- local id = "Air820"
-- local keepAlive = 300
-- local pubtopic = "air820"
-- local subtopic = "lab102"


local host = "47.108.188.160"
local port = 1883
local user = "test"
local pwd = "test"
local id = "Air820"
local keepAlive = 300
local pubtopic = "t/air820"
local subtopic = "lab102"

phone_num1 = "0"

-- _G.phone_num2 = "0"
-- _G.phone_num3 = "0"

-- phonelist={}
-- phonelist[1]=phone_num1
-- phonelist[2]=phone_num2
-- phonelist[3]=phone_num3

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

function re_phone_num()
    -- return phonelist
    return phone_num1
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
    imei=misc.getImei()
    imei = tostring(imei)
    while true do
        sys.wait(3000)
        transBlng = fgps.returnBlng()
        transBlat = fgps.returnBlat()
        -- data = transBlng.."+"..transBlat
        local workMode = ftask.ReWm()
        local t = os.date("*t")
        local time =string.format("%04d-%02d-%02d %02d:%02d:%02d", t.year,t.month,t.day,t.hour,t.min,t.sec)
        local torigin =
        {
            imei = imei,
            lng = transBlng,
            lat = transBlat,
            t = time,
        }
        local jsondata = json.encode(torigin)
        data = jsondata
        -- log.info("测试测试", data)
        -- log.info("时间时间时间", string.format("%04d-%02d-%02d %02d:%02d:%02d", t.year,t.month,t.day,t.hour,t.min,t.sec).."+"..imei)
        if workMode then
            local pubstatus = mqttc:publish(pubtopic, data, 0)
            if pubstatus then
                log.info("pubstatus", "上传成功")
            else
                log.info("pubstatus", "上传失败")
            end

            -- local substatus = mqttc:subscribe(subtopic, 0)
            -- if substatus then
            --     local r, data, param = mqttc:receive(120000, "pub_msg")
            --     log.info("接收", data.topic,data.payload)
            --     -- faudio.test_01(data.payload)
            --     log.info("首个字母", string.sub(data.payload,1,1)=="a")
            --     if string.sub(data.payload,1,1)=="a" then
            --         phone_num1=string.sub(data.payload,2,-1)
            --         log.info("电话号码",phone_num1)
            --     -- elseif data.payload[1]=='b' then
            --     --     phone_num2=string.sub(data.payload,2,-1)
            --     -- elseif data.payload[1]=='c' then
            --     --     phone_num3=string.sub(data.payload,2,-1)
            --     end

            -- else
            --     log.info("fail", "mqtt接收失败")
            -- end

            sys.wait(5000)
        end
        
    end

    mqttc:disconnect()
end)