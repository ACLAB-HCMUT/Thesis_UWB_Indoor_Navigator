import socket
import paho.mqtt.client as mqtt

ADAFRUIT_IO_USERNAME = ''
ADAFRUIT_IO_KEY = ''

MQTT_HOST = 'io.adafruit.com'
MQTT_PORT = 1883
FEED_NAME = 'serverip'
MQTT_TOPIC = f'{ADAFRUIT_IO_USERNAME}/feeds/{FEED_NAME}'

def on_connect(client, userdata, flags, rc):
    if rc == 0:
        print('Connected successfully')
        client.subscribe(MQTT_TOPIC)
    else:
        print(f'Connection failed with code {rc}')

def on_message(client, userdata, msg):
    print(f'Received message: {msg.payload.decode()} on topic {msg.topic}')

client = mqtt.Client()
client.username_pw_set(ADAFRUIT_IO_USERNAME, ADAFRUIT_IO_KEY)
client.on_connect = on_connect
client.on_message = on_message
client.connect(MQTT_HOST, MQTT_PORT, 60)
client.loop_start()

def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.settimeout(0)
    try:
        s.connect(('10.254.254.254', 1))
        ip_address = s.getsockname()[0]
    except Exception:
        ip_address = '127.0.0.1'
    finally:
        s.close()
    return ip_address

def publishServerIP(ipAddress):
    client.publish(MQTT_TOPIC, ipAddress)
    
publishServerIP(get_local_ip())

try:
    while True:
        pass
except KeyboardInterrupt:
    print('Disconnecting from broker')
    client.loop_stop()
    client.disconnect()