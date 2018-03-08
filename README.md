# **QtCreater 交叉编译环境设置**

---

## **1. 开启开发板WIFI**

修改/etc/wpa_supplicant.conf文件如下

```
ctrl_interface=/var/run/wpa_supplicant
ctrl_interface_group=0
update_config=1

network={
    ssid="Ratta-Enterprise"
    psk="password"
}
```
修改ssid和psk可以连接不同的WIFI。

新建一个startWIFI.sh文件，并将下面的文本复制进去保存。
```
rfkill unblock wlan
killall wpa_supplicant
wpa_supplicant -Dnl80211 -i wlan0 -c /etc/wpa_supplicant.conf & 
udhcpc -i wlan0 -s /usr/share/udhcpc/default.script
```

运行 startWIFI.sh 就可以开启 WIFI
```
$ chmod +x startWIFI.sh
$ ./startWIFI.sh
```

使用以下的命令可以测试是否可以上网
```
$ ping www.baidu.com
```

以下步骤设置完成后，重启开发板，只需运行```./startWIFI.sh 1 > /dev/null```就可以开启WIFI。

## **2. 设置QtCreater**

```fsl-imx6sl-x11-sdk/ fsl-imx6sl-x11-tcqt/ ```交叉编译工具放在 ```/opt/```目录下

**在QtCreater中打开tool>option>Build&Run>Compilers添加交叉编译工具**

    /opt/fsl-imx6sl-x11-sdk/4.1.15-2.1.0/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-g++ 

Name设置为IMX6-GCC

    /opt/fsl-imx6sl-x11-sdk/4.1.15-2.1.0/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-gcc

Name设置为IMX6-GCC

**在Debugger中添加GDB**

    /opt/fsl-imx6sl-x11-sdk/4.1.15-2.1.0/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-gdb
    
设置Name为IMX6 Debugger

**在 Qt Version中添加qmake**

    /opt/fsl-imx6sl-x11-sdk/4.1.15-2.1.0/sysroots/x86_64-pokysdk-linux/usr/bin/qt5/qmake
    
**modify qmake.conf**
Update the mksepc file: /opt/fsl-imx-wayland/4.1.15-2.0.1/sysroots/cortexa7hf-neon-poky-linux-gnueabi/usr/lib/qt5/mkspecs/linux-arm-gnueabi-g++/qmake.conf 

```
@@ -1,5 +1,5 @@ #
-# qmake configuration for building with arm-linux-gnueabi-g++
+# qmake configuration for building with arm-poky-linux-gnueabi-g++ 
#   MAKEFILE_GENERATOR      = UNIX
@@ -11,14 +11,17 @@ 
include(../common/g++-unix.conf)   
# modifications to g++.conf
-QMAKE_CC                = arm-linux-gnueabi-gcc
-QMAKE_CXX               = arm-linux-gnueabi-g++
-QMAKE_LINK              = arm-linux-gnueabi-g++
-QMAKE_LINK_SHLIB        = arm-linux-gnueabi-g++
+QMAKE_CC                = arm-poky-linux-gnueabi-gcc
+QMAKE_CXX               = arm-poky-linux-gnueabi-g++
+QMAKE_LINK              = arm-poky-linux-gnueabi-g++
+QMAKE_LINK_SHLIB        = arm-poky-linux-gnueabi-g++
+
+QMAKE_LFLAGS += --sysroot=/opt/fsl-imx6sl-x11-sdk/4.1.15-2.1.0/sysroots/cortexa9hf-neon-poky-linux-gnueabi -mfloat-abi=hard -mfpu=neon-vfpv4
+QMAKE_CXXFLAGS +=  -mfloat-abi=hard -mfpu=neon-vfpv4  
# modifications to linux.conf
-QMAKE_AR                = arm-linux-gnueabi-ar cqs
-QMAKE_OBJCOPY           = arm-linux-gnueabi-objcopy
-QMAKE_NM                = arm-linux-gnueabi-nm -P
-QMAKE_STRIP             = arm-linux-gnueabi-strip
+QMAKE_AR                = arm-poky-linux-gnueabi-ar cqs
+QMAKE_OBJCOPY           = arm-poky-linux-gnueabi-objcopy
+QMAKE_NM                = arm-poky-linux-gnueabi-nm -P
+QMAKE_STRIP             = arm-poky-linux-gnueabi-strip
 load(qt_config)
```
    
**设置Kits**

Name 设置为 ```IMX6SLEVK```

Device Type 设置为 ```Generic Linux Device```

Sysroot 设置为 ```/opt/fsl-imx6sl-x11-sdk/4.1.15-2.1.0/sysroots/cortexa9hf-neon-poky-linux-gnueabi```

Compiler 设置为 ```IMX6-GCC```

Debugger 设置为 ```IMX6 Debugger```

Qt Version 设置为 ```Qt 5.6.2(qt5)```

Qt mkspec 设置为 ```/opt/fsl-imx6sl-x11-sdk/4.1.15-2.1.0/sysroots/cortexa9hf-neon-poky-linux-gnueabi/usr/lib/qt5/mkspecs/linux-arm-gnueabi-g++```

如下图所示
![Kits 设置][1]

**添加Devices**

添加一个 Generic Linux Device
![添加一个Device][2]

其中 IP 地址 要设置成你自己板子的 IP 地址，在板子上用 ```ifconfig```可以查看。

## **3. 搭个简单文件服务器**

在本地主机上使用以下命令
```
$ mdkir $HOME/SimpleFileServer
$ cd $HOME/SimpleFileServer
$ wget https://github.com/JonYuLi/SetQtCreaterCrossCompile/raw/master/SimpleFileServer
$ chmod +x SimpleFileServer
$ ./SimpleFileServer
```

在浏览器中输入 http://localhost:8080/pollux/ 可以查看文件服务器是否正常运行

## **4. 项目设置**

**在项目的 .pro 文件中添加**

```
target.path = /home/root # path on device
INSTALLS += target

TARGET = /home/username/SimpleFileSever/file/Sn100ForAd

INCLUDEPATH += /opt/fsl-imx6sl-x11-sdk/4.1.15-2.1.0/sysroots/cortexa9hf-neon-poky-linux-gnueabi/usr/include/c++/5.3.0/
INCLUDEPATH += /opt/fsl-imx6sl-x11-sdk/4.1.15-2.1.0/sysroots/cortexa9hf-neon-poky-linux-gnueabi/usr/include/c++/5.3.0/arm-poky-linux-gnueabi/
INCLUDEPATH += /opt/fsl-imx6sl-x11-sdk/4.1.15-2.1.0/sysroots/cortexa9hf-neon-poky-linux-gnueabi/usr/include/

```
把TARGET中的username改成你自己的登录名

在Projects中的Build&Run中添加 IMX6SLEVK 编译工具，并在 Run中的Deployment中禁用 upload files via SFTP
添加一个run costun remote command , 内容如下
```
wget http://192.168.120.146:8080/pollux/Sn100ForAd -O /home/root/Sn100ForAd
```
把 192.168.120.146 替换成本地主机的IP地址

选择用 IMX6SLEVK 编译项目，并运行程序，在 Application Output 中有应用程序的qDebug信息打印就成功了




  [1]: https://github.com/JonYuLi/SetQtCreaterCrossCompile/blob/master/Pictures/QtCreaterKits.png?raw=true
  [2]: https://github.com/JonYuLi/SetQtCreaterCrossCompile/blob/master/Pictures/addDevice.png?raw=true
