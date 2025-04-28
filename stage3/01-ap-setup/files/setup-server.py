from flask import Flask, request, render_template_string
import subprocess
import os
import threading
import time
import RPi.GPIO as GPIO

app = Flask(__name__)

@app.errorhandler(404)
def page_not_found(e):
    return HTML_FORM, 200


LED_PIN = 17
GPIO.setmode(GPIO.BCM)
GPIO.setup(LED_PIN, GPIO.OUT)

blinking = True

def blink_led():
    while blinking:
        GPIO.output(LED_PIN, GPIO.HIGH)
        time.sleep(0.8)
        GPIO.output(LED_PIN, GPIO.LOW)
        time.sleep(0.8)

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
                # Disable AP setup service now that Wi-Fi is configured
                subprocess.run(["systemctl", "disable", "ap-setup.service"])
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
