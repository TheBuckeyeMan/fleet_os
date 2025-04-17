import subprocess
from flask import Flask, request

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def wifi_setup():
    if request.method == "POST":
        ssid = request.form["ssid"]
        password = request.form["password"]

        subprocess.run([
            "nmcli", "device", "disconnect", "wlan0"
        ])
        subprocess.run([
            "nmcli", "device", "wifi", "connect", ssid,
            "password", password, "ifname", "wlan0"
        ])
        return "Wi-Fi setup complete. Rebooting..."
    
    return '''
        <form method="post">
            SSID: <input name="ssid"><br>
            Password: <input name="password" type="password"><br>
            <input type="submit">
        </form>
    '''

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
