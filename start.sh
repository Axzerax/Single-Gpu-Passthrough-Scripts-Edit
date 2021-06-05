# debugging
set -x

# load variables we defined
source "/etc/libvirt/hooks/kvm.conf"

# stop display manager
systemctl stop sddm.service

# Unbind VTconsoles
echo 0 > /sys/class/vtconsole/vtcon0/bind
echo 0 > /sys/class/vtconsole/vtcon1/bind

# Unbind EFI-framebuffer
echo efi-framebuffer.0 > /sys/bus/platform/drivers/efi-framebuffer/unbind

# stop extra nvidia services
systemctl stop nvidia-persistenced
killall plasmashell

# Avoid race condition
sleep 10

# Unload Nvidia
modprobe -r nvidia_drm
modprobe -r nvidia_modeset
modprobe -r drm_kms_helper
modprobe -r nvidia
modprobe -r i2c_nvidia_gpu
modprobe -r drm
modprobe -r nvidia_uvm
modprobe -r ipmi_devintf
modprobe -r ipmi_msghandler

# unbind gpu
virsh nodedev-detach $VIRSH_GPU_VIDEO
virsh nodedev-detach $VIRSH_GPU_AUDIO
virsh nodedev-detach $VIRSH_GPU_USB
virsh nodedev-detach $VIRSH_GPU_USBC

# load vfio
modprobe vfio
modprobe vfio_pci
modprobe vfio_iommu_type1
modprobe vfio_virqfd
