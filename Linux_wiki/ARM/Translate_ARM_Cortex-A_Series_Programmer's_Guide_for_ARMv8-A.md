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

以下是一些术语的简要概述和一个图表，展示了缓存的基本结构：

The tag is the part of a memory address stored within the cache that identifies the main memory address associated with a line of data.

标记(Tag)是在高速缓存中存储的一部分内存地址，它标识了与数据线相关联的主内存地址。


The top bits of the 64-bit address tell the cache where the information came from in main memory and is known as the tag.

64位地址的高位部分告诉缓存信息来自主存的哪个位置，这被称为标签。

The total cache size is a measure of the amount of data it can hold, although the RAMs used to hold tag values are not included in the calculation. 

总缓存大小是衡量它能够容纳数据量的一个指标，但用于保存标记值的 RAM 不计入计算。

The tag does, however, take up physical space in the cache.

然而，标签占据缓存中的实际空间。


It would be inefficient to hold one word of data for each tag address, so several locations are typically grouped together under the same tag. 

每个标签地址都存储一个单词的数据会效率低下，因此通常会将几个位置分组在同一个标签下。

This logical block is commonly known as a cache line, and refers to the smallest loadable unit of a cache, a block of contiguous words from main memory.

A cache line is said to be valid when it contains cached data or instructions, and invalid when it does not.



Associated with each line of data are one or more status bits. Typically, you have a valid bit that marks the line as containing data that can be used. 

This means that the address tag represents some real value. In a data cache, you might also have one or more dirty bits that mark whether the cache line (or part of it) holds data that is not the same as (newer than) the contents of main memory.



The index is the part of a memory address that determines in which lines of the cache the address can be found.



The middle bits of the address, or index, identify the line.

The index is used as address for the cache RAMs and does not require storage as a part of the tag. 

This is covered in more detail later in this chapter.



A way is a subdivision of a cache, each way being of equal size and indexed in the same fashion. A set consists of the cache lines from all ways sharing a particular index.



This means that the bottom few bits of the address, called the offset, are not required to be stored in the tag.

You require the address of a whole line, not of each byte within the line, so the five or six least significant bits are always 0.




[]()
[]()
[]()
[]()
[]()
[]()
