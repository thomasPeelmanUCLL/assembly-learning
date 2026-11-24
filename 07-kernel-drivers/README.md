# 07-kernel-drivers — Intro to Linux Device Drivers

Two modules, in order:

## 1. `hello/` — your first kernel module

```bash
cd hello
make
make load          # insmod + dmesg
dmesg | tail       # "hello: module loaded"
make unload
```

## 2. `messagebox/` — a character device

```bash
cd messagebox
make
make load

echo "hello kernel" | sudo tee /dev/messagebox
cat /dev/messagebox
make unload
```

## Where to build

### Debian/Ubuntu VM (recommended for first attempts)

```bash
sudo apt install build-essential linux-headers-$(uname -r)
```

A kernel bug panics the whole machine — use a VM or spare hardware.

### NixOS

Kernel headers live in `linuxPackages.kernel.dev`. Quick test shell:

```bash
nix-shell -p linuxPackages.kernel.dev stdenv
```

Then point the Makefile at it:

```bash
make KDIR=$(nix-build '<nixpkgs>' -A linuxPackages.kernel.dev --no-out-link)/lib/modules/*/build
```

For modules loaded at boot, add them declaratively:

```nix
boot.extraModulePackages = [ (config.boot.kernelPackages.callPackage ./messagebox.nix { }) ];
```

(See the NixOS manual's `extraModulePackages` section for the package
definition pattern.) For learning, a VM is simpler — iterate there first.

## Concepts covered

- `module_init` / `module_exit` lifecycle and `pr_info` logging (see `dmesg`)
- Character devices: `alloc_chrdev_region` + `cdev` + `class_create`/`device_create`
- `file_operations`: how `read()`/`write()` syscalls dispatch into your driver
- `copy_to_user` / `copy_from_user`: the kernel/user memory boundary

## Exercises

1. Add an `ioctl` handler (`unlocked_ioctl`) that clears the message buffer.
2. Make `mb_read` return the message only once per open (hint: use
   `filp->private_data` to track state).
3. In assembly (lesson 04 style), write a small program that opens
   `/dev/messagebox` with the `open` syscall and writes to it — you now
   speak both sides of the syscall boundary.
4. Bonus: convert `messagebox` to the modern misc-device API
   (`misc_register`) and compare the boilerplate.
