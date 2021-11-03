--- 模块功能：音频功能测试.
-- @author 范润泽
-- @module audio.testAudio
-- @license MIT
-- @copyright openLuat
-- @release 2018.03.19

module(...,package.seeall)
--require"record"
require"audio"
require"common"

--音频播放优先级，对应audio.play接口中的priority参数；数值越大，优先级越高，用户根据自己的需求设置优先级
--PWRON：开机铃声
--CALL：来电铃声
--SMS：新短信铃声
--TTS：TTS播放
--REC:录音音频
PWRON,CALL,SMS,TTS,REC = 4,3,2,1,0

local function testCb(r)
    log.info("testAudio.testCb",r)
end

--播放音频文件测试接口，每次打开一行代码进行测试
local function testPlayFile()
    --单次播放来电铃声，默认音量等级
    --audio.play(CALL,"FILE","/lua/call.mp3")
    --单次播放来电铃声，音量等级7
    --audio.play(CALL,"FILE","/lua/call.mp3",audiocore.VOL7)
    --单次播放来电铃声，音量等级7，播放结束或者出错调用testcb回调函数
    --audio.play(CALL,"FILE","/lua/call.mp3",audiocore.VOL7,testCb)
    --循环播放来电铃声，音量等级7，没有循环间隔(一次播放结束后，立即播放下一次)
    audio.play(CALL,"FILE","/lua/call.mp3",audiocore.VOL7,nil,true)
    --循环播放来电铃声，音量等级7，循环间隔为2000毫秒
    --audio.play(CALL,"FILE","/lua/call.mp3",audiocore.VOL7,nil,true,2000)
end


--播放tts测试接口，每次打开一行代码进行测试
--audio.play接口要求TTS数据为UTF8编码，因为本文件编辑时采用的是UTF8编码，所以可以直接使用ttsStr，不用做编码转换
--如果用户自己编辑脚本时，采用的不是UTF8编码，需要调用common.XXX2utf8接口进行转换
--local ttsStr = "上海合宙通信科技有限公司欢迎您"
-- local ttsStr = "贵州大学大数据与信息工程学院"
local function testPlayTts(tStr)
    --单次播放，默认音量等级
    --audio.play(TTS,"TTS",ttsStr)
    --单次播放，音量等级7
    audio.play(TTS,"TTS",tStr,7)
    --单次播放，音量等级7，播放结束或者出错调用testcb回调函数
    --audio.play(TTS,"TTS",ttsStr,7,testCb)
    --循环播放，音量等级7，没有循环间隔(一次播放结束后，立即播放下一次)
    --audio.play(TTS,"TTS",ttsStr,7,nil,true)
    --循环播放，音量等级7，循环间隔为2000毫秒
    -- audio.play(TTS,"TTS",ttsStr,7,nil,true,2000)
end



function test_01(fStr)
    testPlayTts(fStr)
end

