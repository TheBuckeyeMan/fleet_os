import RPi.GPIO as GPIO
import os
import time
import subprocess

# COnfiguration
RESET_PIN = 21
DEBOUNCE_MS = 300
FIRMWARE_DIR = "/boot/firmware"

#Files to Delete
FILES_TO_DELETE = [
    "provisioned.txt",
    "device-info.json",
    "iot_certificate.pem"
]

#Setup
GPIO.setmode(GPIO.BCM)
GPIO.setup(RESET_PIN, GPIO.IN, pull_up_down=GPIO.PUD_UP)

def handle_reset(channel):
    print("[RESET] Button pressed. Beginning factory reset...")
    # 1. Delete provisioning-related files
    for filename in FILES_TO_DELETE:
        path = os.path.join(FIRMWARE_DIR, filename)
        try:
            if os.path.exists(path):
                os.remove(path)
                print(f"[RESET] Deleted: {path}")
            else:
                print(f"[RESET] File not found (skipped): {path}")
        except Exception as e:
            print(f"[ERROR] Could not delete {path}: {e}")

    # 2. Delete saved Wi-Fi networks via nmcli
    try:
        print("[RESET] Clearing saved Wi-Fi connections...")
        result = subprocess.run(["nmcli", "-t", "-f", "NAME", "connection", "show"],
                                capture_output=True, text=True)
        ssids = result.stdout.strip().split("\n")
        for ssid in ssids:
            if ssid and ssid != "ap-mode":
                subprocess.run(["nmcli", "connection", "delete", ssid])
                print(f"[RESET] Deleted Wi-Fi profile: {ssid}")
            elif ssid == "ap-mode":
                print(f"[RESET] Preserved AP profile: {ssid}")
    except Exception as e:
        print(f"[ERROR] Failed to clear Wi-Fi connections: {e}")

    # 3. Optional: Wait briefly before reboot
    print("[RESET] Reset complete. Rebooting in 3 seconds...")
    time.sleep(3)

    # 4. Reboot the device
    subprocess.run(["reboot"])


# Detect rising edge (button press)
GPIO.add_event_detect(RESET_PIN, GPIO.RISING, callback=handle_reset, bouncetime=DEBOUNCE_MS)

print("[RESET] Reset button monitor running. Waiting for button press...")

try:
    while True:
        time.sleep(1)
except KeyboardInterrupt:
    print("\n[RESET] Exiting reset monitor...")
finally:
    GPIO.cleanup()
