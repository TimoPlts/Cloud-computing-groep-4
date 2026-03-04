import os, json, time, random
import paho.mqtt.client as mqtt

host = os.getenv("MQTT_HOST", "localhost")
port = int(os.getenv("MQTT_PORT", "1883"))
user = os.getenv("MQTT_USER", "")
pw   = os.getenv("MQTT_PASS", "")

def on_connect(client, userdata, flags, rc, properties=None):
    print("Connected:", rc)

client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)
client.on_connect = on_connect
if user:
    client.username_pw_set(user, pw)

client.connect(host, port, 60)
client.loop_start()

while True:
    joystick = {"x": random.randint(-50, 1100), "y": random.randint(0, 1023)}  # soms fout
    buttons = {"a": random.choice([0, 1, 2]), "b": random.choice([0, 1])}      # soms fout
    client.publish("controller/joystick", json.dumps(joystick), qos=0, retain=False)
    client.publish("controller/button", json.dumps(buttons), qos=0, retain=False)
    time.sleep(1)