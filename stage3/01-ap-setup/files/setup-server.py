from flask import Flask, request, render_template_string
import subprocess
import os
import threading
import time
import RPi.GPIO as GPIO

app = Flask(__name__)


#Check if WIFI credentials already exist
def is_wifi_connected():
    try:
        result = subprocess.run(
            ["nmcli", "-t", "-f", "DEVICE,STATE", "device"],
            capture_output=True, text=True
        )
        for line in result.stdout.strip().split('\n'):
            device, state = line.split(":")
            if device == "wlan0" and state == "connected":
                return True
    except Exception as e:
        print(f"Error checking WiFi status: {e}")
    return False

# If wifi credentials exist, exit the script do not display form to enter new credentials
if is_wifi_connected():
    print("WiFi credentials already set. Exiting...")
    exit(0)

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

# Start Blinking Thread
blink_thread = threading.Thread(target=blink_led)
blink_thread.start()


HTML_FORM = """
<html><body>
<div>
<h2>Enter Device WiFi Credentials</h2>
<form method="POST">
SSID: <input type="text" name="ssid"><br>
Password: <input type="password" name="password"><br>
<input type="submit" value="Connect">
</form>
</div>
</body></html>
"""

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        ssid = request.form.get('ssid')
        password = request.form.get('password')
        if ssid and password:
            result = subprocess.run([
                "nmcli", "device", "wifi", "connect", ssid, "password", password
            ], capture_output=True, text=True)
            if result.returncode == 0:
                blinking = False
                GPIO.output(LED_PIN, GPIO.LOW)
                return f"""
                <html><body>
                <h2>✅ Connected to {ssid}!</h2>
                <p>The device will now reboot and try to join your WiFi.</p>
                <pre>{result.stdout}</pre>
                <script>setTimeout(() => fetch('/reboot'), 3000);</script>
                </body></html>
                """
            else:
                return f"""
                <html><body>
                <h2>❌ Failed to connect to {ssid}</h2>
                <pre>{result.stderr}</pre>
                <a href="/">Try again</a>
                </body></html>
                """
    return HTML_FORM

@app.route('/reboot')
def reboot():
    subprocess.Popen(['reboot'])
    return "Rebooting..."

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
