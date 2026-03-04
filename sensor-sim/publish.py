import os, json, time, random
import paho.mqtt.client as mqtt

host = os.getenv("MQTT_HOST", "localhost")
port = int(os.getenv("MQTT_PORT", "1883"))
user = os.getenv("MQTT_USER", "")
pw   = os.getenv("MQTT_PASS", "")


def on_connect(client, userdata, flags, rc, properties=None): # Callback wordt opgeroepen als client met broker verbindt
    print("Connected:", rc)# rc = result code (0 = OK)

# Maak een MQTT client aan
client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)# CallbackAPIVersion.VERSION2 is nodig voor nieuwe paho-mqtt versies
client.on_connect = on_connect # Koppel de on_connect callback aan de client

client.connect(host, port, 60) # 60 = keepalive
client.loop_start()

while True:
    joystick = {"x": random.randint(0, 1023), "y": random.randint(0, 1023)}  
    buttons = {"a": random.choice([0, 1, 2]), "b": random.choice([0, 1, 2])}     
    client.publish("controller/joystick", json.dumps(joystick), qos=0, retain=False)
    client.publish("controller/button", json.dumps(buttons), qos=0, retain=False)
    time.sleep(1)