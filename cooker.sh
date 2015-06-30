#!/bin/bash
#############################################################
#              KERNEL COOKER V-1.0 by zakee94               #
#############################################################
# This script is to be placed in the root of your kernel directory.
# By default supports Moto G 2014, however can be modified for ANY device.
# Personal Space --> (your paths)
export CROSS_COMPILE=< your path > # self explanatory
BOOT=arch/arm/boot # DO NOT CHANGE THIS !
defconfig=< name of your defconfig > # self explanatory
archive_name=< as you wish > # name of the zip file which will be generated
my_zip=/home/kernel-cooker/my-zips # enter your path if you would like to keep generated zips in a separate place after being made
anykernel=/home/kernel-cooker/anykernel-zip/kernel/ # path of anykernel folder where you are required to place zImages
bootimg=/home/kernel-cooker/bootimg # path where you wiil input zImage and get boot.img as output
                                    # this path should point to the place where dt.img, mkboot.img & ramdisk.gz is kept
bootzip_dir=/home/kernel-cooker/bootimg-zip # path where boot.img will go to after being made and get zipped
# boot.img creation parameters --> (change according to need)
CMDLINE=console=ttyHSL0,115200,n8 androidboot.console=ttyHSL0 androidboot.hardware=qcom user_debug=31 msm_rtb.filter=0x37 vmalloc=400M utags.blkdev=/dev/block/platform/msm_sdcc.1/by-name/utags
PAGESIZE=2048
BASE=0x00000000
RAMDISK_OFFSET=0x01000000
TAGS_OFFEST=0x00000100
# Stores current directory to be used later -->
clear
curr_dir="$(pwd)"
# The beginning -->
echo -e "|------------------------------------------------------------|"
echo -e "|                      KERNEL COOKER                         |"
echo -e "|------------------------------------------------------------|"
echo -e "\nWELCOME $USER, LETS BEGIN..."
echo -e "To begin enter y or Y, any other character to exit."
read begin
if [[ "$begin" == "y" || "$begin" == "Y" ]]; then
  echo -e "\n------------------------------------------------------------"
  echo -e "\nChecking for previous builds..."
    if [ -a $BOOT/Image ] || [ -a $BOOT/zImage ] || [ -a $BOOT/zImage-dtb ]; then
    echo -e "\nPREVIOUS BUILD DETECTED !"
    echo -e "Do you want to clean it ?"
    echo -e "To clean enter y or Y, any other character to remain dirty."
    read clean
      if [[ "$clean" == "y" || "$clean" == "Y" ]]; then
        rm $BOOT/zImage-dtb $BOOT/zImage $BOOT/Image
      fi
    else
      echo -e "\nPREVIOUS BUILD NOT DETECTED. :)"
    fi
  echo -e "\n------------------------------------------------------------"
  echo -e "\nMake clean & make Mrproper ??"
  echo -e "To clean enter y or Y, any other character to remain dirty."
  read proper
  if [[ "$proper" == "y" || "$proper" == "Y" ]]; then
    make clean && make mrproper
    echo -e "\nDONE !"
  fi
  echo -e "\n------------------------------------------------------------"
  echo -e "\nMake defconfig ??"
  echo -e "To make enter y or Y, any other character to not make."
  read config
  if [[ "$config" == "y" || "$config" == "Y" ]]; then
    if [ -a .config ]; then
      echo -e "\nPrevious .config detected, make sure to clean first"
      echo -e "and then try again !"
    else
      ARCH=arm make $defconfig
      echo -e "\nDONE !"
    fi
  fi
  echo -e "\n------------------------------------------------------------"
  echo -e "\nMake menuconfig ??"
  echo -e "To make enter y or Y, any other character to not make."
  read mn_config
  if [[ "$mn_config" == "y" || "$mn_config" == "Y" ]]; then
    if [ -a .config ]; then
      make menuconfig
      echo -e "\nDONE !"
    else
      echo -e "\n.config not detected, make sure to make defconfig first"
      echo -e "and then try again !"
    fi
  fi
  echo -e "\n------------------------------------------------------------"
  echo -e "\nSTART THE BUILD ??"
  echo -e "To start enter y or Y, any other character to not start."
  read build
  if [[ "$build" == "y" || "$build" == "Y" ]]; then
    if [ -a $BOOT/Image ] || [ -a $BOOT/zImage ] || [ -a $BOOT/zImage-dtb ]; then
    echo -e "\nPrevious build detected  make sure to clean first"
    echo -e "and then try again !"
    else
      make -j5 ARCH=arm
    fi
  fi
  echo -e "\n------------------------------------------------------------"
  echo -e "\nChecking for compiled Images..."
  if [ -a $BOOT/zImage-dtb ] || [ -a $BOOT/zImage ]; then
    echo -e "\nCOMPILED zImage & zImage-dtb DETECTED !"
    echo -e "\nWhat do you want to work with ??"
    echo -e "Enter 1 for zImage & 2 for zImage-dtb"
    read images
    if [[ "$images" == "1" ]]; then
      zimg=zImage
    else
      zimg=zImage-dtb
    fi
    check=0
    while [ $check==0 ]
    do
    echo -e "\n------------------------------------------------------------"
    echo -e "\n[*] Enter 1 for Any-Kernel packaging"
    echo -e "[*] Enter 2 for boot.img packaging"
    echo -e "[*] Enter 3 to exit"
    read kernel
    case $kernel in
      1) # Any-Kernel building starts from here -->
      echo -e "\n------------------------------------------------------------"
      echo -e "\nChecking for previous images in Any-Kernel directoy..."
      if [ -a $anykernel/zImage ] || [ -a $anykernel/zImage-dtb ]; then
        echo -e "\nPrevious images detected !"
        echo -e "\nIt is highly recommended that you clean it."
        echo -e "To clean enter y or Y, any other character to remain dirty."
        read clean_any
          if [[ "$clean_any" == "y" || "$clean_any" == "Y" ]]; then
            rm $anykernel/zImage-dtb $anykernel/zImage
            echo -e "\nCLEANED !"
          else
            echo -e "\nAnyways, the script will continue..."
            echo -e "BUT IF YOU FACE ERRORS, IT'S YOUR OWN FAULT !"
          fi
      else
        echo -e "\nPrevious build not detected. :)"
      fi
      # Copies
      echo -e "\nCopying $zimg into Any-Kernel directory..."
      cp -i $BOOT/$zimg $anykernel
      # Checks and renames
      if [[ "$zimg" == "zImage-dtb" ]]; then
      echo -e "\nRenaming..."
      mv $anykernel/$zimg $anykernel/zImage
      fi
      # Creates the zip archive
      echo -e "\nCreating flashable zip archive..."
      cd $anykernel
      cd ..
      zip -r $archive_name . -x \*.zip
      echo -e "\nALL DONE !!!"
      echo -e "ZIP SUCCESSFULLY CREATED !"
      # Moves if needed
      echo -e "\n------------------------------------------------------------"
      echo -e "\nDo you want to move zip in your prefered directory ??"
      echo -e "To move enter y or Y, any other character to not move."
      read move
      if [[ "$move" == "y" || "$move" == "Y" ]]; then
        echo -e "\nMoving..."
        mv $archive_name.zip $my_zip
        echo -e "\nSuccessfully moved !"
        echo -e "\nHAPPY FLASHING !!! :)"
        echo -e "Exiting script..."
        echo -e "\n------------------------------------------------------------"
        cd $curr_dir
        exit 0
      else
        echo -e "\nHAPPY FLASHING !!! :)"
        echo -e "Exiting script..."
        echo -e "\n------------------------------------------------------------"
        cd $curr_dir
        exit 0
      fi
      exit 0
      ;;
      2) # boot.img building starts here -->
      echo -e "\n------------------------------------------------------------"
      echo -e "\nChecking for previous images in Boot-img directoy..."
      if [ -a $bootimg/zImage ] || [ -a $bootimg/zImage-dtb ] || [ -a $bootimg/boot.img ]; then
        echo -e "\nPrevious images detected !"
        echo -e "\nIt is highly recommended that you clean it "
        echo -e "To clean enter y or Y, any other character to remain dirty."
        read clean_boot
          if [[ "$clean_boot" == "y" || "$clean_boot" == "Y" ]]; then
            rm $bootimg/zImage-dtb $bootimg/zImage $bootimg/boot.img
            echo -e "\nCLEANED !"
          else
            echo -e "\nAnyways, the script will continue..."
            echo -e "BUT IF YOU FACE ERRORS, IT'S YOUR OWN FAULT !"
          fi
      else
        echo -e "\nPrevious build not detected. :)"
      fi
      # Copies
      echo -e "\nCopying $zimg into Boot-img directory..."
      cp -i $BOOT/$zimg $bootimg
      # Makes the boot.img
      cd $bootimg
      echo -e "\nSetting permissions..."
      chmod a+x mkbootimg
      echo -e "\nGenerating boot.img..."
      ./mkbootimg --kernel "$zimg" --ramdisk "ramdisk.gz" --cmdline "$CMDLINE" --pagesize "$PAGESIZE" --base "$BASE" --ramdisk_offset "$RAMDISK_OFFSET" --tags_offset "$TAGS_OFFEST" --dt dt.img --output boot.img
      echo -e "\nboot.img SUCCESSFULLY CREATED !!!"
      # Creates the zip archive
      echo -e "\nCopying generated boot.img into zip directory..."
      cp -i boot.img $bootzip_dir
      echo -e "\nCreating flashable zip archive..."
      cd $bootzip_dir
      zip -r $archive_name . -x \*.zip
      echo -e "\nALL DONE !!!"
      echo -e "ZIP SUCCESSFULLY CREATED !"
      # Moves if needed
      echo -e "\n------------------------------------------------------------"
      echo -e "\nDo you want to move zip in your prefered directory ??"
      echo -e "To move enter y or Y, any other character to not move."
      read move_again
      if [[ "$move_again" == "y" || "$move_again" == "Y" ]]; then
        echo -e "\nMoving..."
        mv $archive_name.zip $my_zip
        echo -e "\nSuccessfully moved !"
        echo -e "\nHAPPY FLASHING !!! :)"
        echo -e "Exiting script..."
        echo -e "\n------------------------------------------------------------"
        cd $curr_dir
        exit 0
      else
        echo -e "\nHAPPY FLASHING !!! :)"
        echo -e "Exiting script..."
        echo -e "\n------------------------------------------------------------"
        cd $curr_dir
        exit 0
      fi
      exit 0
      ;;
      3)
      echo -e "\nExiting script..."
      echo -e "\n------------------------------------------------------------"
      exit 0
      ;;
      *)
      echo -e "\nWrong input entered, try again. ;)"
      check=0
      ;;
    esac
  done
  else
    echo -e "\nNo trace of zImage-dtb. :("
    echo -e "\nThis can be because of 2 reasons :-"
    echo -e "  1. Either you have not build the kernel OR"
    echo -e "  2. Your build is unsuccessfull."
    echo -e "\nPlease try again ! Exiting script..."
    echo -e "\n------------------------------------------------------------"
    exit 0
  fi
else
  echo -e "\nExiting script..."
  echo -e "\n------------------------------------------------------------"
  exit 0
fi
