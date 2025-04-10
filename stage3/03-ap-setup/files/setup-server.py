from flask import Flask, request, render_template_string
import os

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
