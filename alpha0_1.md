# 2021-11-3 Air820实现功能总结

（P.S）现在已经初步具备一个完整的前端产品模块，可对标“小天才电话手表”

程序编写——范润泽

文档编写——范润泽

## 1.空闲模式

全部功能关闭，只用于开机后的等待，通过--长摁--“按键1” 实现模式切换

在空闲模式下，

“按键2”—语音播报—>“请打开监控模式获取定位信息”

“按键3”—语音播报—>“请打开监控模式拨打电话”

## 2.监控模式

开启监控模式后

### 2.1 Gps定位打开

可通过fgps.lua中的延时模块控制获取定位的时间，

可通过“按键2”获取定位信息，并带有语音播报

### 2.2 三轴传感器开启

通过“队列”的数据结构实现线控近来30秒中的位姿，位姿分为正姿、左右倒、前后倒 当出现上述三种位姿达到30秒后会播报相应的姿态

如：“我前后摔倒”、“我左右摔倒”、“我在平稳行走”等

监控时间可通过sensor.lua中延时模块实现

### 2.3 mqtt上传与接收

通过设置上传topic和接收topic实现不同的功能

#### 2.3.1 上传

将得到的gps定位信息（经纬度）上传到mqtt相应的pub-topic中

#### 2.3.2 接收

监听相应sub-topic的数据，判断是否为a开头的信息，如果为a开头，会将后面的信息（电话号码），更改到“拨打电话”中去

***实现通过手机端更改  前端设备拨打的电话号码  这一功能***

#### 2.4 拨打电话

初始电话号码为0，当前段设备开启“监控模式”时，手机端可通过发送对应的topic信息更改电话号码

如：发送“a123456789”，前端设备接收到以a为开头的数据时，会自动把a后面的数据传给电话号码这个变量

按下“按键3”——>实现拨打对应电话的功能，并播报“拨打xxxxxx”

#### 2.5 开关机

通过长按power-key键“5秒”实现关机操作

短按power-key实现开机