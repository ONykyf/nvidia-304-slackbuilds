# nvidia-304-slackbuilds

SlackBuilds with the necessary sources to build legacy NVidia drivers (kernel modules, X drivers, and nvidia utilities) version 304 (for Curie cards and older, 32 bit and 64 bit).

This is a work in progress based on a [Slackware package](https://www.linuxquestions.org/questions/slackware-14/nvidia-legacy304-kernel-on-current-4175700054/page2.html#post6321261) from JayByrd at [linuxquestions.org](https://www.linuxquestions.org/questions/slackware-14/) and Connor Martin’s [fork](https://github.com/MajorCadence/nvidia-304) of [https://github.com/flydiscohuebr/nvidia-304](https://github.com/flydiscohuebr/nvidia-304).

It is an attempt to adapt slackbuilds for NVidia 340 from [nvidia-340-390-470-580-slackbuilds](https://github.com/Onykyf/nvidia-340-390-470-580-slackbuilds).
The package is suited to be used with [XLibre](https://github.com/ONykyf/X11Libre-SlackBuild) xserver on Slackware and uses some Xlibre-specific directives in `/usr/share/X11/xorg.conf.d/10-{nvidia,nvidia-modules}.conf`, but should work well with Xorg xserver if several lines in these config files are adjusted.

Below are verbatim excerpts from README [nvidia-340-390-470-580-slackbuilds](https://github.com/Onykyf/nvidia-340-390-470-580-slackbuilds), which are not guaranteed to be quite correct and will be edited after testing if necessary. Please consult [https://github.com/flydiscohuebr/nvidia-304](https://github.com/flydiscohuebr/nvidia-304) for more detailed and actual information.

## Objectives

- To allow a user to install NVidia drivers on systems with recent Linux kernels (tested up to 7.0.3) so that they "just work", with little to no manual intervention;

- To make NVidia packages safe in the sense that if NVidia card is absent or disabled, then the legacy drivers' presence does not affect the system;

- In particular, to install proprietary modules and libraries in a dedicated directory `/usr/{lib,lib64}/nvidia` so that they do not overwrite open versions from XLibre, Mesa etc;

- To avoid the need for rebuilding the kernel and enabling `lkdtm.ko` module;

- To keep `nouveau` kernel and X drivers so that a user is able to choose between them and `nvidia` at boot time, which increases safety (it's almost impossible for both open and proprietary drivers to break simultaneously).

## Source

The build scripts are distant descendants of [slackbuilds](https://slackbuilds.org/result/?search=nvidia-legacy&sv=15.0)  by Heinz Wiesinger, Edward W. Koenig, and Lenard Spencer.

Patches are almost entirely taken from [https://github.com/MajorCadence/nvidia-304](https://github.com/MajorCadence/nvidia-304).

Tags `SBo` are changed to `Nyk` to emphasize that [slackbuilds.org](https://slackbuilds.org/result/?search=nvidia-legacy&sv=15.0) is not responsible for these packages.

## Prerequisites

It is assumed that you use the XLibre version for Slackware provided at [https://github.com/ONykyf/X11Libre-SlackBuild](https://github.com/ONykyf/X11Libre-SlackBuild), which contains PRs not yet merged into XLibre master.
They allow to set not only `ModulePath`s (which is merged into stable and master already), but also `IgnoreABI` for specific `Driver`s and `Module`s, and to enable them only if a DRM device driven by `nvidia-drm` is detected.
Then specially crafted `OutputClass`es in `/usr/share/X11/xorg.conf.d/10-nvidia.conf` (which is an enhanced version of a similar file used in XOrg) and its supplement  `/usr/share/X11/xorg.conf.d/10-nvidia-modules.conf` do the trick.

## How to download

Clone the repository with Git like so:
```
git clone https://github.com/ONykyf/nvidia-304-slackbuilds.git
cd nvidia-304-slackbuilds
```
Using this method gives you the opportunity to later simply update the repository by running `git pull origin main` in `nvidia-304-slackbuilds` directory. Please be advised that the initial download of the Git repository is about 218 Mb.

## How to build and install

Just run `nvidia-legacy304-kernel.SlackBuild` and `nvidia-legacy304-driver.SlackBuild` in the respective directories, and install the obtained packages.

Observe that `*.run` installers from NVidia are one level up in the directory hierarchy to save space. The created packages and build logs are put alongside the build scripts (not in `/tmp` or wherever). You can move them to another place to keep the cloned repository intact and not to lose the built packages in case of a repository update.

Note that `nvidia-legacy304-driver` is common, but `nvidia-legacy304-kernel` should be built and installed separately for all kernels you use (boot each kernel and re-run the build script).

After the installation you will get `/boot/initrd-${KERNEL}.img` initramfs image cleared of `nouveau` and `nvidia` kernel modules, which ensures that they will not be loaded at early boot. To simplify its use, an `/etc/lilo.conf.nvidia-${KERNEL}` snippet is generated simultaneously, which looks like this:
```
# Linux bootable partition config begins
image = /boot/vmlinuz-7.0.3
  root = /dev/sda9
  label = Linux-7.0.3+
  read-only  # Partitions should be mounted read-only for checking
  initrd = /boot/initrd-7.0.3.img
  append = " module_blacklist=nouveau"
# Linux bootable partition config ends
# Linux bootable partition config begins
image = /boot/vmlinuz-7.0.3
  root = /dev/sda9
  label = Linux-7.0.3-
  read-only  # Partitions should be mounted read-only for checking
  initrd = /boot/initrd-7.0.3.img
  append = " module_blacklist=nvidia"
# Linux bootable partition config ends
```
You can add it (edited if you like) to `/etc/lilo.conf` and re-run `lilo` to choose at boot which drivers to use. This adds an additional safety margin in case something goes wrong after an upgrade or an experiment. If you use, say, GRUB2 instead of LILO, you can take kernel options from here to use in `grub.cfg`.

Note that `/boot/initrd-${KERNEL}.img` may be overwritten, e.g., when a kernel is reinstalled. If you encounter problems after this, then running `nvidia-prepare-boot` (and `lilo`, if used) with this kernel booted restores the correct initrd image and points the bootloader to its location.

Version 304 of the NVidia driver is not kernel modesetting capable and hence lacks `nvidia_modeset` kernel module, and DRM functionality is implemented in `nvidia` module, i.e., there is no separate `nvidia_drm`.

*Important note:* you DON'T need to blacklist nouveau in `/etc/modprobe.d/*`. If there is a file that contains a line `blacklist nouveau`, remove it, or unistall `xf86-video-nouveau-blacklist-1.0-noarch-1.txz` package if it has been installed.

## NVidia 304 specific notes

The nvidia 304 driver is not GLVND capable and its installer tries to replace some OpenGL-related libraries with its own versions. This makes `nouveau` drivers not work and should be prevented.
Hence the legacy libraries are moved to `/usr/{lib,lib64}/nvidia`, and the package installs a script `/etc/rc.d/rc.nvidia304` that changes soft links to `libGL` and `libOpenCL` between NVidia and system-wide libraries depending on whether `nvidia.ko` kernel module has been loaded at startup. If `ldconfig` without arguments is run, e.g., from an installation script, then the soft links are "corrected", and you temporarily lose OpenGL for `nvidia`. Then reboot a computer or run `/etc/rc.d/rc.nvidia304` as root.

