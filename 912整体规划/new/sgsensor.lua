module(...,package.seeall)
-- require"tools"
require "LuaQueue"


local ADDR_SC7A20       =  0x19
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


local timer_id
local poseQueue = LuaQueue.reList()
local enable = true
local i2cslaveaddr = 0x18
local function i2cRead(addr,len)
    i2c.send(2,i2cslaveaddr,addr)
    return i2c.recv(2,i2cslaveaddr,len)
end
local function i2cWrite(addr,...)
    return i2c.send(2,i2cslaveaddr,{addr,...})
end
i2cWrite(0x1E,0x05)--打开操作权限，0x1E 寄存器写 0x05
local sl_val = i2cRead(0x57,1) --读取 0x57 寄存器当前配置
if #sl_val > 0 then
    log.info("sl_val", sl_val:toHex())
    sl_val = bit.bor(string.byte(sl_val),0x40) --I2C_PU 置 1
    i2cWrite(0x57,sl_val)

    --设置参数
    i2cWrite(0x20,0x37)
    i2cWrite(0x21,0x11)
    i2cWrite(0x22,0x40)
    i2cWrite(0x23,0x88)
else
    enable = false
end


--球xy加速度、球位置
local bx,by,bxa,bya = 5,5,0,0
--加速度系数（实际为百分之一）
local aa = 3


function update()
    if not enable then
        disp.clear()
        lcd.putStringCenter("板载加速度计无效",120,120,255,255,255)
        return
    end
    local data = i2cRead(0xa8,6)
    --log.info("read i2c",data:toHex())
    if #data ~= 6 then return end
    --Convert the data to 10 bits
    data = string.char(
        data:byte(1)%8,data:byte(2),
        data:byte(3)%8,data:byte(4),
        data:byte(5)%8,data:byte(6)
    )
    local _,xa,ya,za = pack.unpack(data,">HHH")
    if xa > 127 then xa = xa - 256 end
    if ya > 127 then ya = ya - 256 end
    if za > 127 then za = za - 256 end
    --log.info("xyz",xa,ya,za)

    bxa,bya = bxa+ya*aa/100,bya+xa*aa/100--当前加速度+测量加速度
    --计算位移
    bx,by = bx+bxa,by+bya
    --边缘反弹计算
    if bx < 0 then bx = -bx/1.2 bxa = -bxa/1.2 end
    if by < 0 then by = -by/1.2 bya = -bya/1.2 end
    if bx > rw-ballSize then bx = rw-ballSize-(bx-(rw-ballSize))/1.2 bxa = -bxa/1.2 end
    if by > rh-ballSize then by = rh-ballSize-(by-(rh-ballSize))/1.2 bya = -bya/1.2 end
end


local enable = true
local i2cslaveaddr = 0x18
local function i2cRead(addr,len)
    i2c.send(2,i2cslaveaddr,addr)
    return i2c.recv(2,i2cslaveaddr,len)
end
local function i2cWrite(addr,...)
    return i2c.send(2,i2cslaveaddr,{addr,...})
end
local rw,rh = disp.getlcdinfo()
--球xy加速度、球位置
local bx,by,bxa,bya,bza = rw/2,rh/2,0,0,0
--加速度系数（实际为百分之一）
local aa = 5

sys.taskInit(function()
    sys.wait(1000)
    poseQueue:InitSequece(5)
    local sum = 0
	while true do
		i2cid = 2
        i2c.setup(i2cid,i2c.SLOW) 

        i2cWrite(0x1E,0x05)--打开操作权限，0x1E 寄存器写 0x05
		local sl_val = i2cRead(0x57,1) --读取 0x57 寄存器当前配置

        log.info("测试一下", #sl_val)
		if #sl_val > 0 then
			log.info("sl_val", sl_val:toHex())
			sl_val = bit.bor(string.byte(sl_val),0x40) --I2C_PU 置 1

			i2cWrite(0x57,sl_val)

			--设置参数
			-- i2cWrite(0x20,0x37)
			-- i2cWrite(0x21,0x11)
			-- i2cWrite(0x22,0x40)
			-- i2cWrite(0x23,0x88)
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

        if not enable then
            log.info("错误", "加速度计有问题")
            return
        end
        -- local data = i2cRead(0xa8,6)
        local fFlag = i2cRead(0x31,1)
        
        -- log.info("自由落体", #fFlag)
        --log.info("read i2c",data:toHex())
        -- if #data ~= 6 then return end
        -- --Convert the data to 10 bits
        -- data = string.char(
        --     data:byte(1)%8,data:byte(2),
        --     data:byte(3)%8,data:byte(4),
        --     data:byte(5)%8,data:byte(6)
        -- )
        -- if fFlag == '%' then
        --     print('正常行走或停止')
        -- elseif fFlag == '&' then
        --     print('前后倾斜')
        -- elseif fFlag == '）' then
        --     print('左右倾斜')
        -- elseif fFlag == '' then
        --     print('前后倾斜')
        -- elseif fFlag == 'U' then
        --     print('自由落体失重')
        -- end
        log.info("字符串", string.byte(fFlag)..fFlag)
        local poseStatus = tonumber(string.byte(fFlag))
        poseQueue:EnQueue(poseStatus)
        sum = poseQueue:GetAdd()
        log.info("和", sum)
        -- -- local _,ff = pack.unpack(fFlag,">H")
        -- local _,xa,ya,za = pack.unpack(data,">HHH")
        -- if xa > 127 then xa = xa - 256 end
        -- if ya > 127 then ya = ya - 256 end
        -- if za > 127 then za = za - 256 end
        -- -- log.info("xyz",xa,ya,za)
    
        -- bxa,bya,bza = ya*aa/100,xa*aa/100,za*aa/100--当前加速度+测量加速度
        -- --计算位移
        -- bx,by = bx+bxa,by+bya

        -- log.info("测试", bxa.."+"..bya.."+"..bza)
        -- log.info("自由落体", ff)


        
		sys.wait(2000)
	end
end)



