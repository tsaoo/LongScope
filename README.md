# LongScope - Automatic Measurement Solution

- [LongScope - Automatic Measurement Solution](#longscope---automatic-measurement-solution)
  - [简介](#简介)
  - [环境配置](#环境配置)


## 简介
LongScope用于示波器的自动化或远程测量。程序由MATLAB和Python编写，通过VISA接口连接示波器及其它类似设备。用户可以访问测量仪器的完整数据，或通过图形化界面远程设置仪器功能。

![Running Example](<Assets/Running Example.png>)

- **便捷地访问原始、完整的测量数据。** LongScope允许直接从仪器读取超过10MB（取决于仪器存储深度）的原始数据，并以.CSV等格式保存。
- **直接连接MATLAB/Python程序。** LongScope运行在MATLAB平台上，用户程序可以将其用作透明的仪器接口，实时分析或转发测量数据。
- **支持多种示波器型号。** LongScope使用通用的VISA（Virtual instrument software architecture，虚拟仪器接口）连接示波器，并兼容多个厂商的应用层协议。

LongScope是面对对象的，每种仪器的方法封装在仪器型号对应的类中，这些类继承自一个统一的抽象类InstDev，抽象类规定了每种仪器必须实现的方法（例如波形读取）以及必须维护的属性（例如当前的触发电平）。虽然每种仪器使用的命令格式可能不同，不同仪器类的方法是以相同格式调用的，各种属性也以相同格式存储。因此，与仪器的通信对于应用层（LongScope的GUI或其它用户程序）是透明的。

## 环境配置

1. **下载LongScope**

    现阶段推荐直接pull。如果不参与LongScope开发，可以下载Release中的安装包，这样不需要安装Matlab工具箱，但仍需要pip安装pyvisa。

2. **安装pyvisa** [![Static Badge](https://img.shields.io/badge/Github-pyvisa-blue)](https://github.com/pyvisa/pyvisa)

        $ pip install pyvisa

3. **安装Matlab Instrument Control Toolbox**