/*
 * messagebox: a character device driver you can write to and read from.
 *
 *   echo "hi" | sudo tee /dev/messagebox
 *   cat /dev/messagebox
 *
 * Demonstrates: alloc_chrdev_region, cdev, file_operations,
 * copy_from_user / copy_to_user, device_create (udev node).
 */
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/uaccess.h>
#include <linux/string.h>

#define BUF_SIZE 256

static dev_t devnum;
static struct cdev cdev;
static struct class *cls;
static char msg[BUF_SIZE];
static size_t msg_len;

static int mb_open(struct inode *ino, struct file *filp)
{
    pr_info("messagebox: opened\n");
    return 0;
}

static ssize_t mb_read(struct file *filp, char __user *buf,
                       size_t count, loff_t *ppos)
{
    size_t to_read = min(count, msg_len);

    if (*ppos >= msg_len)
        return 0;                       /* EOF */
    if (copy_to_user(buf, msg, to_read))
        return -EFAULT;
    *ppos += to_read;
    return to_read;
}

static ssize_t mb_write(struct file *filp, const char __user *buf,
                        size_t count, loff_t *ppos)
{
    size_t to_write = min(count, (size_t)BUF_SIZE - 1);

    if (copy_from_user(msg, buf, to_write))
        return -EFAULT;
    msg[to_write] = '\0';
    msg_len = to_write;
    pr_info("messagebox: stored %zu bytes\n", to_write);
    return to_write;
}

static int mb_release(struct inode *ino, struct file *filp)
{
    pr_info("messagebox: closed\n");
    return 0;
}

static const struct file_operations mb_fops = {
    .owner   = THIS_MODULE,
    .open    = mb_open,
    .read    = mb_read,
    .write   = mb_write,
    .release = mb_release,
};

static int __init mb_init(void)
{
    int ret;

    ret = alloc_chrdev_region(&devnum, 0, 1, "messagebox");
    if (ret)
        return ret;

    cdev_init(&cdev, &mb_fops);
    ret = cdev_add(&cdev, devnum, 1);
    if (ret)
        goto err_region;

    cls = class_create("messagebox");
    if (IS_ERR(cls)) {
        ret = PTR_ERR(cls);
        goto err_cdev;
    }
    device_create(cls, NULL, devnum, NULL, "messagebox");

    pr_info("messagebox: loaded, major=%d minor=%d\n",
            MAJOR(devnum), MINOR(devnum));
    return 0;

err_cdev:
    cdev_del(&cdev);
err_region:
    unregister_chrdev_region(devnum, 1);
    return ret;
}

static void __exit mb_exit(void)
{
    device_destroy(cls, devnum);
    class_destroy(cls);
    cdev_del(&cdev);
    unregister_chrdev_region(devnum, 1);
    pr_info("messagebox: unloaded\n");
}

module_init(mb_init);
module_exit(mb_exit);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("grid777");
MODULE_DESCRIPTION("Character device message box");
