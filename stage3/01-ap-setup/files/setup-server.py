from flask import Flask, request, render_template_string, redirect, url_for
import subprocess
import os
import threading
import time
import RPi.GPIO as GPIO

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
<h2>Enter Device WiFi Credentials</h2>
<form method="POST">
SSID: <input type="text" name="ssid" style="width:100%;"><br><br>
Password: <input type="password" name="password" style="width:100%;"><br><br>
<input type="submit" value="Connect" style="width:100%;padding:10px;">
</form>
</div>
</body>
</html>
"""

ATTEMPT_PAGE = """<html><body>
<h2>✅ Credentials Received</h2>
<p>Device is testing the connection now.<br>
This page may close or disconnect as the device reboots.</p>
</body></html>"""

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
        blink_thread = threading.Thread(target=blink_led)
        blink_thread.start()
        app.run(host='0.0.0.0', port=80)