from flask import Flask, request, render_template_string, redirect, url_for
import subprocess
import os
import threading
import time
import RPi.GPIO as GPIO
import json
from datetime import datetime, timezone

app = Flask(__name__)

# --- LED Setup ---
LED_PIN = 17
GPIO.setmode(GPIO.BCM)
GPIO.setup(LED_PIN, GPIO.OUT)

blinking = True

def blink_led():
    while blinking:
        GPIO.output(LED_PIN, GPIO.HIGH)
        time.sleep(0.3)
        GPIO.output(LED_PIN, GPIO.LOW)
        time.sleep(0.3)

# --- HTML Form ---
HTML_FORM = """
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>WiFi Setup</title>
</head>
<body>
<div style="max-width:400px;margin:auto;text-align:center;">
<h2>Enter Device Information</h2>
<form method="POST">
<h3>Enter Wifi Credentials</h3>
Wifi Name(SSID): <input type="text" name="ssid" style="width:100%;" required><br><br>
Password: <input type="password" name="password" style="width:100%;" required><br><br>
<h3>Enter Business Credentials</h3>
<p><strong>Claim Code</strong> for your business can be found via web portal where you signed up at http://example.com - <strong>This Claim Code Must Match Exactly</strong></p>
Claim Code: <input type="text" name="claim_code" style="width:100%;" required><br><br>
<p><strong>Device Business Location</strong> describes what location this device is located at for businesses with multiple locations - <strong>Must be the same accross all devices at this location</strong></p>
Device Business Location: <input type="text" name="device_business_location" style="width:100%;" required><br><br>
<p><strong>Device Local Location</strong> describes the physical location of this device(I.E. Front Door, Back Door, Zone 1, Area 2) - Multiple Devices can have the same device location if they are located in the same spot.</p>
Device Local Location: <input type="text" name="device_local_location" style="width:100%;" required><br><br>
<input type="submit" value="Connect" style="width:100%;padding:10px;">
</form>
</div>
</body>
</html>
"""

ATTEMPT_PAGE = """<html><body>
<h2>✅ Credentials Received</h2>
<p>Device is testing the connection now.</p><br>
<h3>Successfully Connected?</h3>
<p>If the device connects successfully, your LED will stop blinking and turn solid red after the reboot sequence takes place (<60 Seconds).</p><br>
<p>This page may close or disconnect as the device reboots.</p>
<h3>Device LED Still Blinking after 10 Seconds?</h3>
<p>The Entered Wifi Credentials were incorrect or the device is unable to connect to the network. Please disconnect from the network, forget the network, and reconnect to the network</p>
</body></html>"""

# Get the device Serial Number Method
def get_device_serial():
    try:
        with open('/proc/cpuinfo', 'r') as f:
            for line in f:
                if line.startswith('Serial'):
                    return line.strip().split(':')[1].strip()
    except:
        return "ERROR: UNKNOWN SERIAL NUMBER"

# --- Routes ---
@app.route("/", methods=["GET", "POST"])
@app.route("/hotspot-detect.html", methods=["GET", "POST"])
@app.route("/ncsi.txt", methods=["GET", "POST"])
def index():
    global blinking
    if request.method == "POST":
        ssid = request.form.get("ssid")
        password = request.form.get("password")
        if ssid and password:
            blinking = False
            #Create File with Device Info
            device_info = {
                "serial_number": get_device_serial(),
                "claim_code": request.form.get("claim_code"),
                "device_business_location": request.form.get("device_business_location"),
                "device_local_location": request.form.get("device_local_location"),
                "device_type": "door_sensor",  # CHANGE BASED OFF OF SENSOR TYPE - OS SPECIFIC
                "firmware_version": "v1.0.2",  # CHANGE WITH EVERY NEW RELEASE VERSION
                "device_create_date_time_stamp": datetime.now(timezone.utc).isoformat(),
                "device_create_date_stamp": datetime.now(timezone.utc).date().isoformat()
            }

            with open("/boot/firmware/device-info.json", "w") as f:
                json.dump(device_info, f, indent=2)

            # Work with the LED Light
            time.sleep(2)
            GPIO.output(LED_PIN, GPIO.LOW)
            monitor_thread = threading.Thread(target=monitor_wifi_led, daemon=True) # Start the real-time LED monitor
            monitor_thread.start()
            # Run Wi-Fi connect + reboot after slight delay
            def connect_and_reboot():
                time.sleep(3)  # let browser render success first
                result = subprocess.run([
                    "nmcli", "device", "wifi", "connect", ssid, "password", password
                ], capture_output=True, text=True)

                if result.returncode == 0:
                    
                    with open("/boot/firmware/provisioned.txt", "w") as f:
                        f.write(f"Connected to {ssid} at {time.ctime()}\n")
                    subprocess.Popen(["reboot"])
                else:
                    print(f"WiFi connect failed:\n{result.stderr}")
                    global blinking
                    blinking = True
                    blink_thread = threading.Thread(target=blink_led)
                    blink_thread.start()

            threading.Thread(target=connect_and_reboot).start()
            return ATTEMPT_PAGE
    return HTML_FORM

@app.route('/reboot')
def reboot():
    subprocess.Popen(['reboot'])
    return "Rebooting..."

@app.route('/success')
def success():
    ssid = request.args.get('ssid', 'your WiFi')
    return f"""
    <html><body>
    <h2>✅ Connected to {ssid}!</h2>
    <p>The device will now reboot and join your WiFi.</p>
    <script>setTimeout(() => fetch('/reboot'), 3000);</script>
    </body></html>
    """

# --- Captive Portal 404 Handler --- 
@app.errorhandler(404)
def page_not_found(e):
    return redirect("http://setup"), 302


@app.route("/generate_204")
def generate_204():
    return "", 204

# TODO Break into seporate file 
def monitor_wifi_led():
    while True:
        result = subprocess.run(
            ["nmcli", "-t", "-f", "DEVICE,STATE", "device"],
            capture_output=True, text=True
        )
        if "wlan0:connected" in result.stdout:
            GPIO.output(LED_PIN, GPIO.HIGH)
        else:
            GPIO.output(LED_PIN, GPIO.LOW)
        time.sleep(1)

# --- Start Server ---
if __name__ == '__main__':
    if os.path.exists("/boot/firmware/provisioned.txt"):
        print("[INFO] Device Wifi already connected — skipping Flask Server.")
        monitor_thread = threading.Thread(target=monitor_wifi_led, daemon=True)
        monitor_thread.start()
        while True:
            time.sleep(60)
    else:
        print("[INFO] Not connected to WiFi — starting pairing mode.")
        blinking = True
        blink_thread = threading.Thread(target=blink_led)
        blink_thread.start()
        app.run(host='0.0.0.0', port=80)