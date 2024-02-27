==

工具链==

## Anlogic

TD结合Modelsim软件仿真

https://blog.csdn.net/qq_42151264/article/details/125527778

http://www.taodudu.cc/news/show-6536714.html?action=onClick

直接看官方手册就够了..... [TD_User_Guide_V5.6.pdf](file:///E:/0Projects/芯片手册/TD_User_Guide_V5.6.pdf) 

```markdown
cd D:/Modelsim_win64_SE_10.5_and_crack/modeltech64_10.5/anlogic
```

实验室电脑

```
cd D:/modeltech64_10.5/anlogic
```

新建一个仿真器件库，执行如下的流程

1、复制仿真模型到modelsim库里

2、新建Library，建立相对应芯片的仿真库，并添加

3、先点compile，编译需要的所有文件（包括testbench）

4、再点simulate--->start simulation, 在design目录下的work文件夹下找到需要的testbench，取消勾选enable optimization,  选择需要的library,  执行。

![1698744707950](.\simulate.assets\1698744707950.png)

## Modelsim 

常用的命令，以及操作方法

modelsim仿真时需要什么：HDL设计文件、芯片器件的仿真库、



ROM仿真无法读出数据的坑：

https://blog.csdn.net/qq_44956862/article/details/118722018：

https://blog.csdn.net/wangkuijun/article/details/127327603







## Vivado

仿真方法

1. 独立仿真
2. 联合modelsim仿真

文件结构

vivado和modelsim联合仿真  https://zhuanlan.zhihu.com/p/36516368

==do脚本自动化测试==

需要切换到当前工程的仿真目录，如`E:/0Projects/learn_vivado/learn_vivado.sim/sim_1/behav/modelsim`，在该目录下会有三个do文件，运行  `do   xxxx.do`，即可执行相应的操作，省去手动修改。

启发：命令行、脚本化测试

可参考：https://zhuanlan.zhihu.com/p/98076509

https://zhuanlan.zhihu.com/p/339719511

https://max.book118.com/html/2017/0602/111117497.shtm



==快捷方式==

1. 上下箭头，可以用来切换信号
2. 左右箭头，用来在信号边沿之间进行跳变
3. Ctrl + Q，显示或隐藏左侧快捷栏
4.  **Ctrl+Tab**. 切换下一个窗口   /    **Ctrl+shift+Tab**.   切换上一个窗口





==自定义快捷键==

tools--->settings--->shortcuts

- shift + B，reset behaviroal simulation
- shift + M，run behavioral simulation







## 通用工具

TCL Script   TK

do file

qemu硬件模拟器？







