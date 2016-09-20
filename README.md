The OrangePi-Kernel contains Linux kernel sources (3.4.112) adapted for OrangePI H3 boards, gcc toolchain
The included build script "build_linux_kernel.sh" can be used to build the kernel

example：
$ cd OrangePI-Kernel
$ sudo ./build_linux_kernel.sh clean clean                   cleans the kernel tree before build
$ sudo ./build_linux_kernel.sh plus                          builds the uImage for OPI-PLUS
$ cd ../OrangePi-BuildLinux     
$ sudo ./create_image                                        build file system
$ sudo ./image_from_dir ./linux-trusty orangepi ext4 plus    build plus image
$ sudo dd bs=4M if=orangepi.img of=/dev/sd*                  


After BOOTING,to resize linux partition to fill sd card
$ sudo fs_resize
$ sudo reboot
to install desktop run,please wait at least fifteen minutes
$ sudo ./install_lxde_desktop  
$ sudo reboot           

Read and edit "params.sh" to adjust the parameters to your needs
