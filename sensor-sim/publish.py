import os, json, time, random
import paho.mqtt.client as mqtt

host = os.getenv("MQTT_HOST", "localhost")
port = int(os.getenv("MQTT_PORT", "1883"))


def on_connect(client, userdata, flags, rc, properties=None): # Callback wordt opgeroepen als client met broker verbindt
    print("Connected:", rc)# rc = result code (0 = OK)


def on_disconnect(client, userdata, flags, rc, properties=None):
    if rc == 0:
        print("Disconnected cleanly")
    else:
        print("Unexpected disconnect:", rc)

# Maak een MQTT client aan
client = mqtt.Client(mqtt.CallbackAPIVersion.VERSION2)# CallbackAPIVersion.VERSION2 is nodig voor nieuwe paho-mqtt versies
client.on_connect = on_connect # Koppel de on_connect callback aan de client
client.on_disconnect = on_disconnect

client.connect(host, port, 60) # 60 = keepalive
client.loop_start()

try:
    while True:
        joystick = {"x": random.randint(0, 1023), "y": random.randint(0, 1023)}
        buttons = {"a": random.choice([0, 1, 2]), "b": random.choice([0, 1, 2])}

        joystick_result = client.publish("controller/joystick", json.dumps(joystick), qos=0, retain=False)
        button_result = client.publish("controller/button", json.dumps(buttons), qos=0, retain=False)

        if joystick_result.rc != mqtt.MQTT_ERR_SUCCESS:
            print("Publish joystick failed:", joystick_result.rc)
        if button_result.rc != mqtt.MQTT_ERR_SUCCESS:
            print("Publish button failed:", button_result.rc)

        time.sleep(1)
except KeyboardInterrupt:
    print("Stopping simulator")
finally:
    client.loop_stop()
    client.disconnect()