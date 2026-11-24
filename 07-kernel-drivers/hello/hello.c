; 07-kernel-drivers: hello world kernel module (C, not asm this time)
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>

static int __init hello_init(void)
{
    pr_info("hello: module loaded\n");
    return 0;
}

static void __exit hello_exit(void)
{
    pr_info("hello: module unloaded\n");
}

module_init(hello_init);
module_exit(hello_exit);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("grid777");
MODULE_DESCRIPTION("My first kernel module");
