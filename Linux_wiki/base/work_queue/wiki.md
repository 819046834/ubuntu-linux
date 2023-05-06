


Linux 工作队列是一种异步执行任务的机制，它允许将一些需要延迟执行的任务放入队列中，然后在适当的时候执行这些任务。工作队列通常用于处理一些不需要立即执行的后台任务，例如定时器处理、网络数据包处理等。

工作队列的实现基于内核中的软中断机制，它使用一个单独的内核线程来执行队列中的任务。当一个任务被添加到工作队列中时，它会被放入一个队列中，并且在适当的时候被执行。工作队列的执行是异步的，因此它不会阻塞当前进程的执行。

工作队列的使用非常简单，只需要定义一个工作队列对象，然后使用相应的函数将任务添加到队列中即可。例如，下面的代码演示了如何使用工作队列来实现一个简单的定时器：

```
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/workqueue.h>
#include <linux/slab.h>

static struct workqueue_struct *my_wq;
struct my_work {
    struct work_struct work;
    int data;
};

static void my_wq_function(struct work_struct *work)
{
    struct my_work *my_work = (struct my_work *)work;
    printk(KERN_INFO "my_work.data = %d
", my_work->data);
    kfree((void *)work);
    return;
}

static int __init my_init(void)
{
    struct my_work *work;
    my_wq = create_workqueue("my_queue");
    if (!my_wq)
        return -ENOMEM;

    work = (struct my_work *)kmalloc(sizeof(struct my_work), GFP_KERNEL);
    if (work) {
        INIT_WORK((struct work_struct *)work, my_wq_function);
        work->data = 42;
        queue_work(my_wq, (struct work_struct *)work);
    }
    return 0;
}

static void __exit my_exit(void)
{
    flush_workqueue(my_wq);
    destroy_workqueue(my_wq);
    return;
}

module_init(my_init);
module_exit(my_exit);
```

在上面的代码中，我们首先定义了一个名为 `my_work` 的结构体，它包含一个 `work_struct` 对象和一个整型数据 `data`。

然后，我们定义了一个名为 `my_wq_function` 的函数，它将在工作队列中执行。在这个函数中，我们将打印出 `my_work.data` 的值，并释放 `my_work` 对象的内存。

接下来，我们在 `my_init` 函数中创建了一个名为 `my_queue` 的工作队列，并将一个 `my_work` 对象添加到队列中。最后，在 `my_exit` 函数中，我们清空了工作队列并销毁了它。

总的来说，工作队列是 Linux 内核中非常有用的一种机制，它可以帮助我们实现一些需要延迟执行的后台任务。


```
创建工作队列
struct workqueue_struct *my_wq;
my_wq = create_workqueue("my_queue");

struct my_work {
    struct work_struct work;
    int data;
};

work是具体要做的事
struct my_work *work;
work = (struct my_work *)kmalloc(sizeof(struct my_work), GFP_KERNEL);
        INIT_WORK((struct work_struct *)work, my_wq_function); // 初始化work
        work->data = 42;
        queue_work(my_wq, (struct work_struct *)work); // 把work填充到工作队列中，内核会在合适时机调度运行该工作队列中的work





include/linux/workqueue.h

struct work_struct {
	atomic_long_t data;
	struct list_head entry;
	work_func_t func;
#ifdef CONFIG_LOCKDEP
	struct lockdep_map lockdep_map;
#endif
	ANDROID_KABI_RESERVE(1);
	ANDROID_KABI_RESERVE(2);
};
struct delayed_work {
	struct work_struct work;
	struct timer_list timer;

	/* target workqueue and CPU ->timer uses to queue ->work */
	struct workqueue_struct *wq;
	int cpu;

	ANDROID_KABI_RESERVE(1);
	ANDROID_KABI_RESERVE(2);
};

struct rcu_work {
	struct work_struct work;
	struct rcu_head rcu;

	/* target workqueue ->rcu uses to queue ->work */
	struct workqueue_struct *wq;
};



kernel/workqueue.c

struct workqueue_struct {
	struct list_head	pwqs;		/* WR: all pwqs of this wq */
	struct list_head	list;		/* PR: list of all workqueues */

	struct mutex		mutex;		/* protects this wq */
	int			work_color;	/* WQ: current work color */
	int			flush_color;	/* WQ: current flush color */
	atomic_t		nr_pwqs_to_flush; /* flush in progress */
	struct wq_flusher	*first_flusher;	/* WQ: first flusher */
	struct list_head	flusher_queue;	/* WQ: flush waiters */
	struct list_head	flusher_overflow; /* WQ: flush overflow list */

	struct list_head	maydays;	/* MD: pwqs requesting rescue */
	struct worker		*rescuer;	/* MD: rescue worker */

	int			nr_drainers;	/* WQ: drain in progress */
	int			saved_max_active; /* WQ: saved pwq max_active */

	struct workqueue_attrs	*unbound_attrs;	/* PW: only for unbound wqs */
	struct pool_workqueue	*dfl_pwq;	/* PW: only for unbound wqs */

#ifdef CONFIG_SYSFS
	struct wq_device	*wq_dev;	/* I: for sysfs interface */
#endif
#ifdef CONFIG_LOCKDEP
	char			*lock_name;
	struct lock_class_key	key;
	struct lockdep_map	lockdep_map;
#endif
	char			name[WQ_NAME_LEN]; /* I: workqueue name */

	/*
	 * Destruction of workqueue_struct is RCU protected to allow walking
	 * the workqueues list without grabbing wq_pool_mutex.
	 * This is used to dump all workqueues from sysrq.
	 */
	struct rcu_head		rcu;

	/* hot fields used during command issue, aligned to cacheline */
	unsigned int		flags ____cacheline_aligned; /* WQ: WQ_* flags */
	struct pool_workqueue __percpu *cpu_pwqs; /* I: per-cpu pwqs */
	struct pool_workqueue __rcu *numa_pwq_tbl[]; /* PWR: unbound pwqs indexed by node */
};
```






ChatGPT 的难点，在于 Prompt（提示词）的编写，
只要你的 Prompt 写的足够好，ChatGPT 可以帮你快速完成很多工作，为了能更好的掌握 Prompt 工程，DeepLearning.ai 创始人吴恩达与 OpenAI 开发者 Iza Fulford 联手推出了一门面向开发者的技术教程：《ChatGPT 提示工程》。

吴恩达的课程，原版链接如下，https://learn.deeplearning.ai/chatgpt-prompt-eng/lesson/1/introduction

B站，https://www.bilibili.com/video/BV1No4y1t7Zn?p=1

只要20分钟就可以get到跟知识管理相关的内容，请看以下提示：

第四集6分钟是一个我们常用的场景，让AI读取用户评论并给出20个字的总结。

第五集8分钟，是提取主题词的场景，可以用于大量AAR文本分析，统计一段时间内部门AAR中提到的问题，同样可以用于反向给文章自动打标签。

第八集，讲述了如何构建一个客服机器人，用一个“温度”参数来控制机器人回答的靠谱性，避免胡说八道。






玩ChatGPT的方式
1.1 入门级-Bing系列（适用于网络未管制PC）
准备
切海外代理：网络未管制PC，代理切换至非中国（含HK）的代理
Edge浏览器（Win10自带）
注册微软账号
切换“国家/地区”到美丽国

开启
Bing Chat：https://www.bing.com/
Bing Image Creator：https://www.bing.com/images/create
1.2 入门级-WeTab插件（任意PC，甚至不需要代理）
准备
浏览器安装插件：https://www.wetab.link/
注册WeTab账号
开启
打开WeTab插件
首页有个Chat AI的Widget，背后是一些代理了GPT API的网站

1.3 入门级-HuggingChat（任意设备，无需代理，但不支持中文）
准备
N/A

开启
https://huggingface.co/chat

1.4 入门级-Stable Diffusion（任意设备，无需代理）
准备
网络未管制PC：接入***（因为***必须加代理才能上网，所以不能用）
Others设备：N/A
开启
https://stablediffusionweb.com/#demo

2.1 工作级-OpenAI真身（适用于网络未管制PC，需要代理）
准备
切海外代理（选Saudi Arabia，东南亚的几个代理已经不可用了）
注册OpenAI账号（需要海外手机号）
开启
ChatGPT：https://chat.openai.com/
ChatGPT Playground（更不容易被禁）：https://platform.openai.com/playground
DALL·E（要打钱才可用，不如去嫖NewBing的）：https://labs.openai.com/
2.2 工作级-OpenAI真身（适用于网络未管制PC，需要代理）
准备
切海外代理（选Saudi Arabia，东南亚的几个代理已经不可用了）
注册OpenAI账号（需要海外手机号）
开启
ChatGPT：https://chat.openai.com/
ChatGPT Playground（更不容易被禁）：https://platform.openai.com/playground
DALL·E（要打钱才可用，不如去嫖NewBing的，或者）：https://labs.openai.com/
3.1 专业级-爬梯大法（任意设备，终极解决方案）
准备
架梯子，我推荐v2ray（免费，下载地址：https://itlao5.com/5951.html ）
配置v2ray代理（我用的是：https://v2.itlao5.com/v2 ），大致步骤如下

开启
ChatGPT同上
NewBing同上
Others…













