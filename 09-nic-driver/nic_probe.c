/*
 * nic_probe: a minimal PCI driver skeleton that finds and identifies
 * the ethernet controller on your machine (or in a VM) and maps its
 * MMIO registers. This is step one of talking to a NIC directly.
 *
 * Load it and check dmesg + lspci to compare.
 */
#include <linux/module.h>
#include <linux/pci.h>
#include <linux/io.h>

#define E1000_VENDOR 0x8086
#define E1000_82540  0x100e      /* QEMU's default e1000 NIC */

static const struct pci_device_id nic_ids[] = {
    { PCI_DEVICE(E1000_VENDOR, E1000_82540) },
    { 0, }
};
MODULE_DEVICE_TABLE(pci, nic_ids);

static int nic_probe(struct pci_dev *pdev, const struct pci_device_id *id)
{
    void __iomem *mmio;
    u32 status;

    if (pci_enable_device(pdev))
        return -ENODEV;

    pci_set_master(pdev);            /* allow the NIC to do DMA */

    /* BAR 0 holds the NIC's register file (MMIO) */
    mmio = pci_iomap(pdev, 0, 0);
    if (!mmio)
        goto err_disable;

    /* STATUS register (offset 0x00008) — link state, speed, duplex */
    status = ioread32(mmio + 0x00008);
    pr_info("nic_probe: %04x:%04x  STATUS=0x%08x  link_up=%d speed=%s\n",
            pdev->vendor, pdev->device, status,
            !!(status & (1 << 1)),               /* LU bit */
            ((status >> 6) & 3) == 2 ? "1000Mb/s" : "other");

    pci_iounmap(pdev, mmio);
    return 0;

err_disable:
    pci_disable_device(pdev);
    return -ENOMEM;
}

static void nic_remove(struct pci_dev *pdev)
{
    pci_disable_device(pdev);
    pr_info("nic_probe: released device\n");
}

static struct pci_driver nic_driver = {
    .name     = "nic_probe",
    .id_table = nic_ids,
    .probe    = nic_probe,
    .remove   = nic_remove,
};

module_pci_driver(nic_driver);
MODULE_LICENSE("GPL");
MODULE_AUTHOR("grid777");
MODULE_DESCRIPTION("Probe an e1000 NIC and read its STATUS register via MMIO");
