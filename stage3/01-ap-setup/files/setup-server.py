# --- stage3/01-ap-setup/files/setup-server.py ---
from flask import Flask, request, render_template_string
import os
import subprocess

app = Flask(__name__)

HTML_FORM = """
<html><body>
<h2>Enter WiFi Credentials</h2>
<form method="POST">
SSID: <input type="text" name="ssid"><br>
Password: <input type="password" name="password"><br>
<input type="submit" value="Connect">
</form>
</body></html>
"""

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        ssid = request.form.get('ssid')
        password = request.form.get('password')
        if ssid and password:
            wpa_supplicant = f"""
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1
country=US

network={{
    ssid=\"{ssid}\"
    psk=\"{password}\"
}}"""
            with open('/boot/firmware/wpa_supplicant.conf', 'w') as f:
                f.write(wpa_supplicant)
            subprocess.run(['sync'])
            os.system('reboot')
        return "Rebooting with new config..."
    return HTML_FORM

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)