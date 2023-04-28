ARM64寄存器   
寄存器:说明

X0 ~ X7:用于传递子程序参数和结果，使用时不需要保存，多余参数采用堆栈传递。
64位返回结果采用 X0 表示，128位返回结果采用 X1:X0 表示。

X8:用于保存子程序返回地址， 尽量不要使用。

X9 ~ X15:临时寄存器，使用时不需要保存。

X16 ~ X17：子程序内部调用寄存器，使用时不需要保存，尽量不要使用。

X18	平台寄存器，它的使用与平台相关，尽量不要使用。

X19 ~ X28：临时寄存器，使用时必须保存。

X29/FP：FP（ Frame Pointer ）栈底指针（64bit）

X30/LR：LR（Link Register）程序链接寄存器（64bit），保存子程序结束后需要执行的下一条指令

X31/SP：SP（Stack Pointer）栈指针（64bit），使用 SP/WSP来进行对SP寄存器的访问。

PC:程序计数器（64bit），俗称PC指针，总是指向即将要执行的下一条指令。
在arm64中，软件是不能改写PC寄存器的。

CPSR:状态寄存器，在arm64位上用pstate代替

注   
1、ARM64寄存器有两种使用模式，64位时称为 X0 ~ X30，32位时称为 W0 ~ W30。

2、ARM64的LR、FP放在栈顶，而ARM放在栈底；

ARM64中当前FP和SP相同，都是栈顶指针，与x86的BP和SP不同，x86的BP和SP之间是整个函数栈帧；

函数返回时，ARM64先将栈中的LR值放入当前LR，再ret；而ARM直接将栈中的LR值放入PC；

使用gcc编译选项-fomit-frame-pointer，可以使ARM64不使用FP寄存器，这时栈帧稍有变化，栈不在保存FP，局部变量寻址过程也不使用该寄存器。


ARM汇编：汇编中proc、endp、ret、near、far指令用法

子程序名 PROC NEAR ( 或 FAR )
……
ret
子程序名 ENDP
（1）NEAR属性(段内近调用): 调用程序和子程序在同一代码段中,只能被相同代码段的其他程序调用;
FAR属性(段间远调用): 调用程序和子程序不在同一代码段中,可以被相同或不同代码段的程序调用.

（2）proc是定义子程序的伪指令，位置在子程序的开始处，它和endp分别表示子程序定义的开始和结束两者必须成对出现。

（3）ret指令的内部操作是：栈顶字单元出栈，其值赋给IP寄存器。即实现了一个程序的转移，将栈顶字单元保存的偏移地址作为下一条指令的偏移地址。

来自 <https://blog.csdn.net/weibo1230123/article/details/84235296>

[ARMv8体系结构基础05：比较和跳转指令]<https://blog.csdn.net/chenchengwudi/article/details/123917082>


1. 前言
WFI(Wait for interrupt)和WFE(Wait for event)是两个让ARM核进入low-power standby模式的指令，由ARM architecture定义，由ARM core实现。它们的区别是什么？使用场景是什么？

SEV：唤醒指令

WFI/WFE：休眠指令

2.WFI和WFE

WFI(Wait for interrupt)和WFE(Wait for event)是两个让ARM核进入low-power standby模式的指令。

这两条指令的作用都是让ARM核进入休眠/待机状态以便降低功耗，但是略有区别：

WFI: wait for Interrupt 等待中断，即下一次中断发生前都在此hold住不干活。

WFE: wait for Events 等待事件，即下一次事件发生前都在此hold住不干活。


1）共同点

WFI和WFE的功能非常类似，以ARMv8-A为例（参考DDI0487A_d_armv8_arm.pdf的描述），主要是“将ARMv8-A PE(Processing Element, 处理单元)设置为low-power standby state”。

需要说明的是，ARM architecture并没有规定“low-power standby state”的具体形式，因而可以由ARM core自行发挥，根据ARM的建议，一般可以实现为standby（关闭clock、保持供电）、dormant、shutdown等等。但有个原则，不能造成内存一致性的问题。以Cortex-A57 ARM core为例，它把WFI和WFE实现为“put the core in a low-power state by disabling the clocks in the core while keeping the core powered up”，即我们通常所说的standby模式，保持供电，关闭clock。

2）不同点

那它们的区别体现在哪呢？主要体现进入和退出的方式上。

对WFI来说，执行WFI指令后，ARM core会立即进入low-power standby state，直到有WFI Wakeup events发生。

而WFE则稍微不同，执行WFE指令后，根据Event Register（一个单bit的寄存器，每个PE一个）的状态，有两种情况：如果Event Register为1，该指令会把它清零，然后执行完成（不会standby）；如果Event Register为0，和WFI类似，进入low-power standby state，直到有WFE Wakeup events发生。

WFI wakeup event和WFE wakeup event可以分别让Core从WFI和WFE状态唤醒，这两类Event大部分相同，如任何的IRQ中断、FIQ中断等等，一些细微的差别，可以参考“DDI0487A_d_armv8_arm.pdf“的描述。而最大的不同是，WFE可以被任何PE上执行的SEV指令唤醒。

所谓的SEV指令，就是一个用来改变Event Register的指令。

SEV指令有两个：SEV和SEVL。

SEV会修改所有PE上的寄存器；

SEVL，只修改本PE的寄存器值。

3. 使用场景
1）WFI

WFI一般用于cpuidle。

2）WFE

WFE的一个典型使用场景，是用在spinlock中（可参考arch_spin_lock，对arm64来说，位于arm64/include/asm/spinlock.h中）。spinlock的功能，是在不同CPU core之间，保护共享资源。使用WFE的流程是：

a）资源空闲

b）Core1访问资源，acquire lock，获得资源

c）Core2访问资源，此时资源不空闲，执行WFE指令，让core进入low-power state

d）Core1释放资源，release lock，释放资源，同时执行SEV指令，唤醒Core2

e）Core2获得资源

以往的spinlock，在获得不到资源时，让Core进入busy loop，而通过插入WFE指令，可以节省功耗。


代码中加入ISB和DSB指令是为了保序，防止CPU乱序功能导致不按程序中代码流程执行的问题。

DSB

数据同步用障是一种特殊类型的内存用障, 只有当此指令执行完毕后,才会执行程序中位于此指令后的指令, 当满足以下条件时,此指
令才会完成:

 位于此指令前的所有显式内存访问均完成。

位于此指令前的所有缓存、跳转预测和 TLB 维护操作全部完成。

允许的值为:

SY

完整的系统 DSB 操作。 这是缺省情况，可以省略。

UN

只可完成于统一点的DSB操作,

ST

存储完成后才可执行的DSB 择作。

UNST

只有当存储完成后才可执行的DSB 操作，并且只会完成于统一点。

ISB

指令同步屏障可刷新处理器中的管道，因此可确保在 ISB 指令完成后，才从高速缓存或内存中提取位于该指令后的其他所有指令。这可确
保提取时间了晚于ISB 指令的指令能够检测到 1SB 指令执行前就已经执行的上下文更改操作的执行效果，例如更改ASID 或已完成的 TLB 维
护操作，跳转预测维护操作以及对 CP15 寄存器所做的所有更改。

此外 ，ISB 指令可确保程序中位于其后的所有跳转指令总会被写入跳转预测逻辑，其写入上下文可确保 ISB 指令后的指令均可检测到这些
跳转指令, 这是指令流能够正确执行的前提条件

option的允许值为:

SY

完整的系统DMB 操作。 这是缺省情况，可以省略。



ARM平台下独占访问指令LDREX和STREX的原理与使用详解

LDREX Rx, [Ry]

读取寄存器Ry指向的4字节内存值，将其保存到Rx寄存器中，同时标记对Ry指向内存区域的独占访问。

STREX Rx, Ry, [Rz]

如果执行这条指令的时候发现已经被标记为独占访问了，则将寄存器Ry中的值更新到寄存器Rz指向的内存，并将寄存器Rx设置成0。指令执行成功后，会将独占访问标记位清除。

而如果执行这条指令的时候发现没有设置独占标记，则不会更新内存，且将寄存器Rx的值设置成1。

一旦某条STREX指令执行成功后，以后再对同一段内存尝试使用STREX指令更新的时候，会发现独占标记已经被清空了，就不能再更新了，从而实现独占访问的机制。

来自 <https://blog.csdn.net/adaptiver/article/details/72392825>

 

独占访问标记位和寄存器Rx用于标记两个不同的操作

独占访问标记位：所有core共用的，用于stxr指令中判断是否更新内存

寄存器Rx         ： 每个core私有的，用于代码中判断是否需要重新对内存操作



执行ldxr指令：

    硬件置位标记位；

执行stxr指令：

          标记位已被置位，更新内存， 硬件清除标记位， 设置Rx为0；

    标记位未被置位，不更新内存，硬件不清除标记位，设置Rx为1；


CBNZ（Compare and Branch on Nozero）指令与CBZ指令编码方式类似，差别在于CBNZ指令是在<Xt>寄存器值不为0时跳转

独占访问标记位和寄存器Rx是两个不同操作的标记的：

独占访问标记位是机器内部做是否独占访问标记的：

执行ldxr指令，硬件设置标记位；

执行stxr指令成功（标记位已标记），硬件清除标记位；

执行stxr指令失败（标记位未标记），不清除标记位；

寄存器Rx的值是用于在程序中判断更新内存是否成功的：

执行stxr指令，更新内存：

成功被设置为0；

失败被设置为1；

ARM平台下独占访问指令LDREX和STREX的原理与使用详解
 https://blog.csdn.net/Roland_Sun/article/details/47670099

Linux内核原子操作（1）基本原理
https://blog.csdn.net/anyegongjuezjd/article/details/125919162

 AXI总线介绍
 https://blog.csdn.net/xsx_6361/article/details/117417083
 
 AXI协议规范超详细中文总结版
 https://blog.csdn.net/HackEle/article/details/125775935?utm_medium=distribute.pc_relevant.none-task-blog-2~default~baidujs_baidulandingword~default-0-125775935-blog-117417083.235^v31^pc_relevant_default_base3&spm=1001.2101.3001.4242.1&utm_relevant_index=3
 
 
 EOR逻辑异或操作指令
 https://blog.csdn.net/shuai532209720/article/details/89791636
 
 EOR指令将< shifter_operand > 表示的数值与寄存器< Rn >值按位做逻辑异或操作，并把结果保存到目标寄存器< Rd > 中，同时根据操作的结果更新CPSR中相应的条件标志位。
 
 指令的语法格式
 
EOR{< cond >} {S} < Rd >, < Rn> ,< shifter_operand >

其中：

< Rn > 寄存器为第1个操作数所在的寄存器。
 
< shifter_operand >为第2个操作数。
 
 指令的使用
 
EOR指令可用于将寄存器中某些位的值取反。将某一位与0做逻辑异或操作，该位的值不变；将某一位与1做逻辑异或操作，该位的值被求反；
 
 示例：
 
 EOR R1, R0, R0, ROR #16 ;R1 = A^C,B^D,C^A,D^B
 
 eor指令将Rn 的值与操作数operand2按位逻辑”异或”，相同为0，不同为1，结果存放到目的寄存器Rd 中。
 
 ARMv8体系结构基础04：算术和移位指令
 
 https://blog.csdn.net/chenchengwudi/article/details/123828339
 
 说明1：异或运算的特点

 任何数和0异或后保持不变
 
 任何数和1异或后取反
 
 说明2：异或运算使用场景示例

根据上述异或运算的特点，就有了如下的使用场景示例，

a.将数值中的指定位翻转;只要将要翻转的位与1异或即可

b.将变量清零
 
c.不借助中间变量交换2个数
 
d.判断两个数是否相等
 
 
 ARM64平台下WFE和SEV相关指令解析
 https://blog.csdn.net/Roland_Sun/article/details/107456179?ops_request_misc=&request_id=&biz_id=102&utm_term=wfe%E5%A6%82%E4%BD%95%E7%94%A8%E6%8C%87%E4%BB%A4%E5%94%A4%E9%86%92&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-5-107456179.142^v86^koosearch_v1,239^v2^insert_chatgpt&spm=1018.2226.3001.4187
 
ARM系列之ARM多核指令WFE、WFI、SEV原理 
 https://blog.csdn.net/xy010902100449/article/details/126812552?ops_request_misc=&request_id=&biz_id=102&utm_term=wfe%E8%A2%AB%E5%94%A4%E9%86%92&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduweb~default-0-126812552.nonecase&spm=1018.2226.3001.4187
 
 
 
 
 
 
 
 
 
 
 
 
