# Custom about file to tel us about the functionality of the raspberry pi OS imager

# Customer Set up Deveice Instructions
1. Plug in the device
2. In wifi settings, you should see the network <Network Name here> Appear
3. Click on the <Network Name Here> and enter the password of <Passwrod>
4. A pop up screen should appear requesting you pass in your wifi credentials, as well as other business related information. Enter the required informationa and press submit
   - If a pop up window does not populate, try the following
     - 1. Forget the network <Network name here> the wifi settings on your phone and reboot and try again. The portal should be displayed
     - 2. If that does not work, connect to the network <Enter Network Name Here>. Once connected, open any web browser(Safari, google, chrome, etc) and type in http://setup. This should display the form and you will beable to submit credentials there
     - 3. If that does not work, connect to the network <Enter NEtwork Name Here>. Once connected, open any web browser(Safari, google, chrome, etc) and type in http://10.42.0.1 The work should then be displayed there. Please fill out and submit
     - 4. If that does not work, Contact our service desk at <Gmail for service desk here>.
Troubleshooting. 
 - If when you open the captive portal and it says "Method Not Aloud" 
    - Exit the captive portal and select "Continue without internet" open any web browser(Safari, google, chrome, etc) and type in http://setup Then, enter all related information there



# ABout
Think of the Raspberry Pi OS as a pipeline for different things that need to occure in the OS, outlined in each stage. Each stage represents the following

Get WIFI Credentials wil be baked into the OS
Install and/or update docker

Logic to get the certificate will exist in a docker container and be pulled to the device and run. It will then get a new cert in the event that the cert doesnt exist and the device is not yet set up
After cert is aquired, then we will need to shut down the docker container and remove it from the list of images as well as containers
pull the new docker images for the logic for the device itself
run the container that has the logic to capture the sensor data, authenticate with IoT Core, as well as send the MQTT Requests to IoT Core

## Updating
### OS
The OS itself(Including tasks to get the wifi crednetials) are not needed

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



# End User
A Captive portal should open as soon as you connect the device, however, if it does not, please open your web browser and type in http://10.42.0.1
