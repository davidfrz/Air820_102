module(...,package.seeall)
-- require"tools"
require "LuaQueue"
require "faudio"
require "ftask"


local ADDR_SC7A20       =  0x19 -- 13-1A
local ADDR_WHO_AM_I     =  0x0F
local ADDR_CTRL_REG_1   =  0x20
local ADDR_CTRL_REG_2   =  0x21
local ADDR_CTRL_REG_3   =  0x22
local ADDR_X_L          =  0x28
local ADDR_X_H          =  0x29
local ADDR_Y_L          =  0x2A
local ADDR_Y_H          =  0x2B
local ADDR_Z_L          =  0x2C
local ADDR_Z_H          =  0x2D
local ADDR_WHO_AM_I     =  0x0F
local ADDR_STATUS_REG   =  0x27

local poseQueue = LuaQueue.reList()
local i2cid = 2
local enable = true
local i2cslaveaddr = 0x18
local function i2cRead(addr,len)
    i2c.send(2,i2cslaveaddr,addr)
    return i2c.recv(2,i2cslaveaddr,len)
end
local function i2cWrite(addr,...)
    return i2c.send(2,i2cslaveaddr,{addr,...})
end

local function i2cInit()
    if i2c.setup(i2cid,i2c.SLOW) ~= i2c.SLOW then
        log.error("I2c.init","fail")
        return
    end
end

local function sensorInit()
    i2cWrite(0x1E,0x05)--打开操作权限，0x1E 寄存器写 0x05
    local sl_val = i2cRead(0x57,1) --读取 0x57 寄存器当前配置
    if #sl_val > 0 then
        log.info("sl_val", sl_val:toHex())
        sl_val = bit.bor(string.byte(sl_val),0x40) --I2C_PU 置 1
        i2cWrite(0x57,sl_val)

        --设置参数
        i2cWrite(0x20,0x57)
        i2cWrite(0x21,0x00)
        i2cWrite(0x22,0x00)
        i2cWrite(0x23,0x00)
        i2cWrite(0x24,0x08)

        i2cWrite(0x30,0x95)
        i2cWrite(0x32,0x1F)
        i2cWrite(0x33,0x05)
    else
        enable = false
    end
end

local function opeSum(num)
    if num == 185 then
        -- faudio.test_01("我在平稳行走")
    elseif num == 125 then
        -- faudio.test_01("我左右摔倒")
    elseif num == 110 then
        -- faudio.test_01("我前后摔倒")
    end
end

local function update(sum)
    if not enable then
        log.error("板载加速度计无效")
        return
    end
    local fFlag = i2cRead(0x31,1)

    log.info("字符串", string.byte(fFlag)..fFlag)
    local poseStatus = tonumber(string.byte(fFlag))
    poseQueue:EnQueue(poseStatus)
    sum = poseQueue:GetAdd()
    log.info("和", sum)
    opeSum(sum)
end

sys.taskInit(function()
    sys.wait(1000)
    poseQueue:InitSequece(5)
    local sum = 0
    i2cInit()
    sensorInit()
	while true do
        local wm = ftask.ReWm()
        -- log.info("工作哈哈哈", wm)
        if wm then
            update(sum)
        end
        sys.wait(2000)
	end
end)



