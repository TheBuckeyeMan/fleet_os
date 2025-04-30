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

# Start LED blinking thread
blink_thread = threading.Thread(target=blink_led)
blink_thread.start()

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

# --- Routes ---

@app.route('/', methods=['GET', 'POST'])
@app.route("/generate_204")
@app.route("/hotspot-detect.html")
@app.route("/ncsi.txt")
def index():
    global blinking
    if request.method == 'POST':
        ssid = request.form.get('ssid')
        password = request.form.get('password')
        if ssid and password:
            # Try to connect
            result = subprocess.run([
                "nmcli", "device", "wifi", "connect", ssid, "password", password
            ], capture_output=True, text=True)
            if result.returncode == 0:
                blinking = False
                GPIO.output(LED_PIN, GPIO.LOW)
                # Disable AP mode (optional for future: disable ap-setup.service here too)
                return redirect(url_for('success', ssid=ssid))
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
    return HTML_FORM, 200

# --- Start Server ---
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)
