# Custom about file to tel us about the functionality of the raspberry pi OS imager

# ABout
Think of the Raspberry Pi OS as a pipeline for different things that need to occure in the OS, outlined in each stage. Each stage represents the following

# File Structure
fleet_os-1
├── config                # 👈 your build configuration (set IMG_NAME, RELEASE, etc.)
├── build.sh              # Build script (native)
├── build-docker.sh       # Build script (Docker)
├── Dockerfile            # Docker image used to run the build in isolation
├── stage0/               # Bootstrap base Debian (not yet bootable)
├── stage1/               # Makes it bootable + minimal system
├── stage2/               # Adds Pi Lite packages (this is the default "Lite" OS)
├── stage3/4/5/           # Desktop, full features, extras (can SKIP these)
└── deploy/               # Final .img or .zip image output (after successful build)

# Config File
This file is responable for defining the global build behavior

IMG_NAME=<Your Image Name>       # 👈 final image filename
RELEASE=bookworm             # Debian release (bookworm = Debian 12) -? Check this for 32 bit raspberry pi light images
ENABLE_SSH=1                 # Enables SSH by default - Eables SSH
FIRST_USER_NAME=pi
FIRST_USER_PASS=raspberry
DISABLE_FIRST_BOOT_USER_RENAME=1
DEPLOY_DIR=./deploy          # Output directory for your .img file
WPA_COUNTRY=US               # Wi-Fi country code



# Stages
Each Stage Defines and represents a layer or stage in the build, each stage has a representation

stage2/
├── 00-packages
├── 00-packages-nr
├── 00-run.sh
├── 00-run-chroot.sh
└── prerun.sh                # Required for each stage we have in the OS

## What each Script DOes
00-packages: List of packages to install (default apt)
00-packages-nr: Same, but with --no-install-recommends
00-run.sh: Host-side script (runs outside the image)
00-run-chroot.sh: Inside-image script (runs inside rootfs in chroot)
prerun.sh: Runs before stage starts, usually copies the previous build rootfs

**Thease run in numbered order, Example, 00-, 01-, 02-, Ect. 

# Defining the High Level for each stage

Stage 0: Bootstraps minimal Debian rootfs using debootstrap
Stage 1: Makes it bootable (adds kernel, config, networking, fstab, etc.)
Stage 2: Raspberry Pi OS Lite setup (adds system tools, Pi configs, pi user, sudo, etc.)
Stage 3: Optional desktop system, full UI, extra packages
Stage 4: Optional desktop system, full UI, extra packages
Stage 5: Optional desktop system, full UI, extra packages

# Custom Stages
We can add a custom stage to our configuraiton making the name of it whatever we want. 
We will be able to insert it in between the other stages using the STAGE_LIST 

## Implementing the Custom Stage
1. In base directory, make a new stage directory
2. in the config file, add or modify the STAGE_LIST="stage0 stage1 stage2 <your stage here - MUST BE IN FORMAT(stage#)>>" to include your new custom stage
2. Add a prerun.sh file to the new directory
4. When adding .sh files, you must run the following command LOCALLY BEFORE YOU PUSH TO GITHUB in order to make the files executable chmod +x <File PAth> (This makes it executable)

# WIFI
#This configuration will
# 1. Read the config and preload the config to wpa_supplicant at /etc/wpa_aupplicant
# 2.Attempt to auto connec to the wifi network specified in the configuration
# 3. Get an ip address for the device via DHCP
#. Be avaliable for SSH using raspberrypi.local on your router assigned IP


# WIFI BOOT PROCESS
WIFI Credentials passed in via ou're going with a Wi-Fi Access Point + captive web form, which is:
✅ Universally supported (iOS, Android, Mac, Windows, etc.)
✅ Scalable (flash and deploy 100s of devices with same image)
✅ The same model used by:
Smart bulbs (TP-Link, Wyze, Tuya)
Cameras (Ring, Blink)
Speakers (Sonos, Bose)
ESP32/ESPHome boards
Commercial IoT devices

 our 00-ap-setup will 
 🔌 Start a Wi-Fi network
🌐 Serve a web form
📶 Let any phone send credentials
💾 Save Wi-Fi config and reboot




On boot, check if Wi-Fi credentials already exist.
✅ If they do exist → connect to Wi-Fi (you already built this).
❌ If they don’t exist → enable Bluetooth, advertise itself, and wait for a phone to connect and send Wi-Fi info.
🧠 Store the credentials → write to /etc/wpa_supplicant/wpa_supplicant.conf
🔁 Reboot or restart networking → Pi auto-connects.

### WIFI Reboots - TODO LATER
A button will be placed on the device which will execute a script to delete the config file at /etc/wpa_supplicant/wpa_supplicant.conf, then restart the device so that it will then attempt to prompt the user to 