# This 
# Runs a flask web server that shows basic HTML Form
# USerr enters SSID and PAssword
# It saves those values directly to the PI's network config
#Sets file permissions for security
# Makrs provisioning as done
#Then, it reboots the pi so it can join the wifi network

from flask import Flask, request, render_template_string
import os

#Validate the Wifi credentials dont exist alread - Is also checked in ap-setup.service before starting this script so if errors, check that
if os.path.exists("/boot/provisioned.flag"):
    print("Already provisioned. Exiting...")
    exit(0)

app = Flask(__name__)

HTML_FORM = '''
<!DOCTYPE html>
<html>
  <head><title>Connect to Wi-Fi</title></head>
  <body>
    <h2>Wi-Fi Setup</h2>
    <form action="/" method="post">
      SSID: <input type="text" name="ssid"><br>
      Password: <input type="password" name="psk"><br>
      <input type="submit" value="Connect">
    </form>
  </body>
</html>
'''

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        ssid = request.form['ssid']
        psk = request.form['psk']
        # Save the credentials to the Pi's Wi-Fi config
        with open("/etc/wpa_supplicant/wpa_supplicant.conf", "w") as f:
            f.write(f'''country=US
ctrl_interface=DIR=/var/run/wpa_supplicant GROUP=netdev
update_config=1

network={{
    ssid="{ssid}"
    psk="{psk}"
    key_mgmt=WPA-PSK
}}''')
        os.system("chmod 600 /etc/wpa_supplicant/wpa_supplicant.conf")
        os.system("touch /boot/provisioned.flag")
        os.system("reboot")
    return render_template_string(HTML_FORM)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
