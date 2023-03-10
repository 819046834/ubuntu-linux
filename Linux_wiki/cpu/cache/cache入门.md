多图详解CPU Cache Memory
来自 <https://blog.csdn.net/juS3Ve/article/details/100135619?spm=1001.2014.3001.5502> 


cache相关名词：
tag：用于区分同一set不同cacheline的
index：寻找是哪一cacheline
offset：cacheline里具体哪一byte数据

way：路，几路就是把cache平分为几份，
set：组，不同way，相同index的cacheline属于同一组
		set内的cacheline是通过不同tag来区分的


遗留问题：

访问cache的地址是虚拟地址还是物理地址？
MMU做地址转换是在访问cache前还是访问cache后？


从wiki中看，貌似是物理地址，









为什么Windows/iOS操作很流畅而Linux/Android却很卡顿呢
来自 <https://blog.csdn.net/dog250/article/details/96362789> 
