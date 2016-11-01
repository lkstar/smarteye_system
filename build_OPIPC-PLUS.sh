# !/bin/bash

ROOT_DIR=${PWD}
KERNEL_DIR=$ROOT_DIR/OrangePi-Kernel
BUILD_DIR=$ROOT_DIR/OrangePi-BuildLinux

CURRENT_TIME=`date +%Y%m%d%H%M`
LOG_FILE=build_$CURRENT_TIME
LOG_FILE_OK=${LOG_FILE}_OK.log
LOG_FILE_ERR=${LOG_FILE}_ERR.log


echo " "
echo "#################################################################################"
echo "Current Path : $ROOT_DIR"
echo "Current Time : $CURRENT_TIME"
echo "Log File Name: $ROOT_DIR/$LOG_FILE_OK"
echo "#################################################################################"
echo " "

#touch $ROOT_DIR/$LOG_FILE_OK

cd $KERNEL_DIR
echo "Enter Director: $KERNEL_DIR"

if [ ! $1 ] ; then
    echo "Do not cleans the kernel tree and build directories"
else
    CLEAN_1ST=clean
    echo "cleans the kernel tree and build directories"
    echo "cleans the kernel tree before build"
    
    #sudo ./build_linux_kernel.sh clean clean >> $ROOT_DIR/$LOG_FILE_OK
    sudo ./build_linux_kernel.sh $CLEAN_1ST clean 
    if [ $? -eq 0 ] ; then
        echo "[OK  ] sudo ./build_linux_kernel.sh clean clean "
    else
        echo "[ERR ] sudo ./build_linux_kernel.sh clean clean "
        #mv $ROOT_DIR/$LOG_FILE_OK $ROOT_DIR/$LOG_FILE_ERR
        #cat $ROOT_DIR/$LOG_FILE_ERR
        echo " "
        echo " "
        exit
    fi
fi

if [ ! $1 ] ; then
    sudo ./build_linux_kernel.sh 2 
else
    #sudo ./build_linux_kernel.sh 2 clean >> $ROOT_DIR/$LOG_FILE_OK
    sudo ./build_linux_kernel.sh 2 $CLEAN_1ST
fi
if [ $? -eq 0 ] ; then
    echo "[OK  ] sudo ./build_linux_kernel.sh 2 $CLEAN_1ST"
else
    echo "[ERR ] sudo ./build_linux_kernel.sh 2 $CLEAN_1ST"
    #mv $ROOT_DIR/$LOG_FILE_OK $ROOT_DIR/$LOG_FILE_ERR
    #cat $ROOT_DIR/$LOG_FILE_ERR
    echo " "
    echo " "
    exit
fi


cd $BUILD_DIR
echo "Enter Director: $BUILD_DIR"

#sudo ./create_image >> $ROOT_DIR/$LOG_FILE_OK
sudo ./create_image
if [ $? -eq 0 ] ; then
    echo "[OK  ] sudo ./create_image "
else
    echo "[ERR ] sudo ./create_image "
    #mv $ROOT_DIR/$LOG_FILE_OK $ROOT_DIR/$LOG_FILE_ERR
    #cat $ROOT_DIR/$LOG_FILE_ERR
    echo " "
    echo " "
    exit
fi



#sudo ./image_from_dir ./linux-trusty orangepi ext4 opi-pcplus >> $ROOT_DIR/$LOG_FILE_OK
sudo ./image_from_dir ./linux-trusty orangepi ext4 opi-pcplus
if [ $? -eq 0 ] ; then
    echo "[OK  ] sudo ./image_from_dir ./linux-trusty orangepi ext4 opi-pcplus "
else
    echo "[ERR ] sudo ./image_from_dir ./linux-trusty orangepi ext4 opi-pcplus "
    #mv $ROOT_DIR/$LOG_FILE_OK $ROOT_DIR/$LOG_FILE_ERR
    #cat $ROOT_DIR/$LOG_FILE_ERR
    echo " "
    echo " "
    exit
fi




echo " "
echo " "
echo "Please run bellow command to create sdcard image":
echo "sudo dd bs=4M if=orangepi.img of=/dev/sd*"
echo " "
echo " "
