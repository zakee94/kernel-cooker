#!/bin/bash
#############################################################
#              KERNEL COOKER V-1.0 by zakee94               #
#############################################################
# This script is to be placed in the root of your kernel directory.
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
    if [ -a $BOOT/Image ] || [ -a $BOOT/zImage ] || [ -a $BOOT/zImage-dtb ] || [ -a .config]; then
    echo -e "\nPREVIOUS BUILD DETECTED !"
    echo -e "\nMake clean & make Mrproper ??"
    echo -e "To clean enter y or Y, any other character to remain dirty."
    read proper
    if [[ "$proper" == "y" || "$proper" == "Y" ]]; then
      make clean mrproper
      echo -e "\nDONE !"
    fi
      else
        echo -e "\nPREVIOUS BUILD NOT DETECTED. :)"
      fi
	fi
  echo -e "\n------------------------------------------------------------"
  echo -e "\nEnter defconfig name"
  echo -e "\nExample: titan_defconfig"
  read defconfig
  echo -e "\nMake defconfig ??"
  echo -e "To make enter y or Y, any other character to not make."
  read config
  if [[ "$config" == "y" || "$config" == "Y" ]]; then
    make $defconfig
    echo -e "\nDONE !"
  fi
  echo -e "\n------------------------------------------------------------"
  echo -e "\nSTART THE BUILD ??"
  echo -e "To start enter y or Y, any other character to not start."
  read build
  if [[ "$build" == "y" || "$build" == "Y" ]]; then
    make -j5
	./dtbToolCM -2 -o out/kernel/dt.img -s 2048 -p scripts/dtc/ arch/arm/boot/
  fi
  echo -e "\n------------------------------------------------------------"
  echo -e "\nChecking for compiled Images..."
  if [ -a $BOOT/zImage-dtb ] || [ -a $BOOT/zImage ]; then
    echo -e "\nCreating AnyKernel ZIP"
	cd out
	zip -r9 kernel.zip *
	cd ..
	echo -e "\n DONE! Zip: out/kernel.zip"
  fi
