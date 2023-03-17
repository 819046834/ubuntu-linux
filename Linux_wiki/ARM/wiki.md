[ARM架构编程](https://www.zhihu.com/column/c_1455195069590962177)


[ARM Cortex-A Series Programmer's Guide for ARMv8-A](https://developer.arm.com/documentation/den0024/a/Caches/Cache-terminology?lang=en)
Cache terminology
缓存术语
In a von Neumann architecture, a single cache is used for instruction and data (a unified cache). 
在冯·诺依曼架构中，使用单个缓存来存储指令和数据（统一缓存）。
A modified Harvard architecture has separate instruction and data buses and therefore there are two caches, an instruction cache (I-cache) and a data cache (D-cache). 
一种改良的哈佛结构具有分离的指令总线和数据总线，因此有两个高速缓存：指令高速缓存（I-cache）和数据高速缓存（D-cache）。
In the ARMv8 processors, there are distinct instruction and data L1 caches backed by a unified L2 cache.
在ARMv8处理器中，有独立的指令和数据L1缓存，由统一的L2缓存支持。
The cache is required to hold an address, some data and some status information.
缓存需要存储地址、一些数据和一些状态信息。
The following is a brief summary of some of the terms used and a diagram illustrating the fundamental structure of a cache:
以下是一些术语的简要概述和一个图表，展示了缓存的基本结构：查看上下文小鲁班(p_xiaoluban)2023-03-17 12:22
		


[]()
[]()
[]()
[]()
[]()
[]()
