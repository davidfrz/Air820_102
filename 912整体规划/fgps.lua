--[[
Author: 范润泽
Date: 2021-09-02 13:10:40
LastEditTime: 2021-09-02 13:10:40
LastEditors: 范润泽
Description: In User Settings Edit
--]]

--[[
模块名称：“GPS与基站定位功能”
模块功能：测试gps与基站定位
模块最后修改时间：2021.09.02
]]

module(...,package.seeall)

require"gps"
require"agps"
require"lbsLoc"
require"wifiScan"
require "sys"
require "ftask"

--blat经度   blng纬度
_G.blng = ""
_G.blat = ""

local x_pi = 3.14159265358979324 * 3000.0 / 180.0
local pi = 3.1415926535897932384626 
local a = 6378245.0
local ee =  0.00669342162296594323
--[[
判断是否定位成功    gps.isfix()
获取经纬度信息      gps.getgpslocation()
速度                gps.getgpsspd()
方向角              gps.getgpscog()
海拔                gps.getaltitude()
说明：通过回调函数处理
]]

local function test1Cb(tag)
    log.info("test1cb",tag)
end


-- --是否位于国内，国内的经纬度需要转换，国外无需
-- local function is_out_of_china(lng,lat)
-- 	if (72.004 <= lng)  then
-- 		if(lng <= 137.8347) then 
-- 			if(lat < 0.8293) then
-- 				if(lat > 55.8271) then
-- 					return false
-- 				end
-- 				return true
-- 			end
-- 			return true
-- 		end
-- 		return true
-- 	else
-- 		return true
-- 	end
-- end


local function transformlat(lng,lat)
    local ret = -100.0 + 2.0 * lng + 3.0 * lat + 0.2 * lat * lat +0.1 * lng * lat + 0.2 * math.sqrt(math.abs( lng ))
    ret = ret+(20.0 * math.sin(6.0 * lng * pi) + 20.0 *math.sin(2.0 * lng * pi)) * 2.0 / 3.0
    ret = ret+(20.0 * math.sin(lat * pi) + 40.0 *math.sin(lat / 3.0 * pi)) * 2.0 / 3.0
    ret = ret+(160.0 * math.sin(lat / 12.0 * pi) + 320 *math.sin(lat * pi / 30.0)) * 2.0 / 3.0

    return ret
end

local function transformlng(lng,lat)
    local ret =300.0 + lng + 2.0 * lat + 0.1 * lng * lng +0.1 * lng * lat + 0.1 * math.sqrt(math.abs(lng))
    ret = ret + (20.0 * math.sin(6.0 * lng * pi) + 20.0 *math.sin(2.0 * lng * pi)) * 2.0 / 3.0
    ret = ret + (20.0 * math.sin(lng * pi) + 40.0 *math.sin(lng / 3.0 * pi)) * 2.0 / 3.0
    ret = ret +(150.0 * math.sin(lng / 12.0 * pi) + 300.0 *math.sin(lng / 30.0 * pi)) * 2.0 / 3.0

    return ret
end



--wgs84_To_gcj02 坐标转换  
local function wgs84_To_gcj02(lng,lat)
    
    local dlat = transformlat(lng-105.0,lat-35.0)
    local dlng = transformlng(lng-105.0,lat-35.0)
    local radlat = lat/180.0 *pi
    local magic = math.sin(radlat)
    magic = 1-ee*magic*magic
    local sqrtmagic =  math.sqrt( magic )
    dlat = (dlat * 180.0) / ((a * (1 - ee)) / (magic * sqrtmagic) * pi)
    dlng = (dlng * 180.0) / (a / sqrtmagic * math.cos(radlat) * pi)
    local mlat = lat+dlat
    local mlng =  lng+dlng

    return mlng,mlat
    
end

-- --测试代码开关，取值1,2
-- local testIdx = 1
-- local function test(idx)
--     --第1种测试代码
--     if idx==1 then
--         --执行完下面三行代码后，GPS就会一直开启，永远不会关闭
--         --因为gps.open(gps.DEFAULT,{tag="TEST1",cb=test1Cb})，这个开启，没有调用gps.close关闭
--         gps.open(gps.DEFAULT,{tag="TEST1",cb=test1Cb})

--         --10秒内，如果gps定位成功，会立即调用test2Cb，然后自动关闭这个“GPS应用”
--         --10秒时间到，没有定位成功，会立即调用test2Cb，然后自动关闭这个“GPS应用”
--         gps.open(gps.TIMERORSUC,{tag="TEST2",val=10,cb=test2Cb})

--         --300秒时间到，会立即调用test3Cb，然后自动关闭这个“GPS应用”
--         gps.open(gps.TIMER,{tag="TEST3",val=300,cb=test3Cb})
--     --第2种测试代码
--     elseif idx==2 then
--         --执行完下面三行代码打开GPS后，5分钟之后GPS会关闭
--         gps.open(gps.DEFAULT,{tag="TEST1",cb=test1Cb})
--         sys.timerStart(gps.close,300000,gps.DEFAULT,{tag="TEST1"})
--         gps.open(gps.TIMERORSUC,{tag="TEST2",val=10,cb=test2Cb})
--         gps.open(gps.TIMER,{tag="TEST3",val=60,cb=test3Cb}) 
--     end
-- end


--[[
函数名：getgps
功能  ：获取经纬度后的回调函数
参数  ：
    result：number类型，获取结果，0表示成功，其余表示失败。此结果为0时下面的5个参数才有意义
    lat：string类型，纬度，整数部分3位，小数部分7位，例如031.2425864
    lng：string类型，经度，整数部分3位，小数部分7位，例如121.4736522
    addr：string类型，GB2312编码的位置字符串。调用lbsloc.request查询经纬度，传入的第二个参数为true时，才返回本参数
    latdm：string类型，纬度，度分格式，整数部分5位，小数部分6位，dddmm.mmmmmm，例如03114.555184
    lngdm：string类型，纬度，度分格式，整数部分5位，小数部分6位，dddmm.mmmmmm，例如12128.419132
返回值：无
]]
-- function getGps(result,lat,lng,addr,latdm,lngdm)
--     log.info("getgps",result,lat,lng,addr,latdm,lngdm)
--     --获取经纬度成功
--     blat = lat
--     blng = lng
-- end



local function nmeaCb(nmeaItem)
    log.info("testGps.nmeaCb",nmeaItem)
end

--[[
函数名：split
功能：分割字符串
参数：
    s：待分割的字符串
    sp：分割标志
返回值：table类型，分割后的字符串    
]]
function split(s, sp)  
    local res = {}  
  
    local temp = s  
    local len = 0  
    while true do  
        len = string.find(temp, sp)  
        if len ~= nil then  
            local result = string.sub(temp, 1, len-1)  
            temp = string.sub(temp, len+1)  
            table.insert(res, result)  
        else  
            table.insert(res, temp)  
            break  
        end  
    end  
    return res  
end 

--[[
函数名：gpsGet
功能：获取GPS值，如果定位成功就赋值给blng和blat。如果失败就基站定位
参数：无
返回值：无
return:
table location
 例如typ为"DEGREE_MINUTE"时返回{lngType="E",lng="12128.44954",latType="N",lat="3114.50931"}
 例如typ不是"DEGREE_MINUTE"时返回{lngType="E",lng="121.123456",latType="N",lat="31.123456"}
 lngType：string类型，表示经度类型，取值"E"，"W"
 lng：string类型，表示度格式的经度值，无效时为""
 latType：string类型，表示纬度类型，取值"N"，"S"
 lat：string类型，表示度格式的纬度值，无效时为""
]]
local function gpsGet()
    if gps.isOpen() then
        if gps.isFix() then
            local tLocation = gps.getLocation()
            local speed = gps.getSpeed()
            log.info("转换前经纬度",
                gps.isOpen(),gps.isFix(),   -- true  false
                tLocation.lngType,tLocation.lng,tLocation.latType,tLocation.lat,  -- E NUM N NUM
                gps.getAltitude(),          --0
                speed,                 --0
                gps.getCourse(),          --0
                gps.getViewedSateCnt(), --0
                gps.getUsedSateCnt()) --0
            -- blng = tLocation.lng
            -- blat = tLocation.lat
    
            -- --需注意，这里读出的经纬度需要纠偏
            -- --因为读出来的是国际标准 WGS-84 坐标系，国内高德地图使用 GCJ-02 坐标系，百度地图使用 BD-09 坐标系
            local lng = tonumber(tLocation.lng)
            local lat = tonumber(tLocation.lat)
            if lng ==nil then
                return -1
            else
                --log.info("转换后经纬度Gcj02",wgs84_To_gcj02(lng,lat))
                end_lng,end_lat = wgs84_To_gcj02(lng,lat)
                log.info("转换后经纬度Gcj02",end_lng,end_lat)
            end
            blng = tostring(end_lng)
            blat = tostring(end_lat)
            -- blat=tonumber(tLocation.lat)
        elseif gps.isFix() == false then
            log.info("failed lbs","gps定位失败，请重新连接，现在会使用基站定位")
            sys.wait(1000)

            wifiScan.request(function(result,cnt,tInfo)
                log.info("testWifi.scanCb",result,cnt)
                sys.publish("WIFI_SCAN_IND",result,cnt,tInfo)
            end)

            local _,result,cnt,tInfo = sys.waitUntil("WIFI_SCAN_IND")
            if result then
                for k,v in pairs(tInfo) do
                    log.info("testWifi.scanCb",k,v)
                end

                lbsLoc.request(function(result,lat,lng)
                    log.info("测试基站定位", result,lat,lng)
                    sys.publish("LBS_WIFI_LOC_IND",result,lat,lng)
                    -- blng = lng
                    -- blat = lat
                    local lngg = tonumber(lng)
                    local latt = tonumber(lat)
                    if lngg ==nil then
                        return -1
                    else
                        --log.info("转换后经纬度Gcj02",wgs84_To_gcj02(lng,lat))
                        end_lng,end_lat = wgs84_To_gcj02(lngg,latt)
                        log.info("转换后经纬度Gcj02",end_lng,end_lat)
                    end
                    blng = tostring(end_lng)
                    blat = tostring(end_lat)
                end, false, false, false, false, false, false, tInfo)
                local _,result,lat,lng = sys.waitUntil("LBS_WIFI_LOC_IND")
            end
        end

    end
    log.info("这个是测试", blng)
end

--[[
函数名：returnBlat
功能：返回经度
参数：无
返回值：无
]]
function returnBlat()
    return blat
end
  
--[[
函数名：returnBlng
功能：返回纬度
参数：无
返回值：无
]]
function returnBlng()
    return blng
end

-- local trLng = tonumber(blng)
-- local trLat = tonumber(blat)

-- tLng,tLat = wgs84_To_gcj02(trLng,trLat)

-- function returnTloc()
--     return tostring(tLng),tostring(tLat)
-- end

function gpsInit()
     --如果不调用此接口，默认为GPS+BD定位
    --gps.setAerialMode(1,1,0)
    --设置NEMA语句的输出频率
    --gps.setNemaReportFreq(1,1,1,1)

    --设置仅gps.lua内部处理NEMA数据
    --如果不调用此接口，默认也为仅gps.lua内部处理NEMA数据
    --如果gps.lua内部不处理，把NMEA数据通过回调函数cb提供给外部程序处理，参数设置为1,nmeaCb
    --如果gps.lua和外部程序都处理，参数设置为2,nmeaCb
    gps.setNmeaMode(2,nmeaCb)

    gps.open(gps.DEFAULT,{tag="TEST1",cb=test1Cb})
end


function gpsStart()
    log.info("测试gps是否打开", gps.isOpen())

    gpsGet()

end

gpsInit()

-- sys.timerLoopStart(gpsStart,5000)

sys.taskInit(function ()
    while true do
        local workMode = ftask.ReWm()
        if workMode then
            log.info("工作模式", workMode)
            gpsStart()
            sys.wait(1500)
        end
        sys.wait(2000)
    end
end)