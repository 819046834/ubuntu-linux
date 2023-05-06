


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

在上面的代码中，我们首先定义了一个名为 `my_work` 的结构体，它包含一个 `work_struct` 对象和一个整型数据 `data`。然后，我们定义了一个名为 `my_wq_function` 的函数，它将在工作队列中执行。在这个函数中，我们将打印出 `my_work.data` 的值，并释放 `my_work` 对象的内存。接下来，我们在 `my_init` 函数中创建了一个名为 `my_queue` 的工作队列，并将一个 `my_work` 对象添加到队列中。最后，在 `my_exit` 函数中，我们清空了工作队列并销毁了它。

总的来说，工作队列是 Linux 内核中非常有用的一种机制，它可以帮助我们实现一些需要延迟执行的后台任务。



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
        queue_work(my_wq, (struct work_struct *)work); // 把work填充到工作队列中，内核会在合适时机调度运行该work










