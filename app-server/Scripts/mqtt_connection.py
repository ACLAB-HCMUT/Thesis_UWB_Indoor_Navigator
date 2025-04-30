import paho.mqtt.client as mqtt
import re
import time
import math

from anchor import Anchor

def parse_mqtt_message(message, height=0.75):
    """
    Parse the MQTT message and return the tag ID and anchor list.
    Message format: [TAG1:{an0:12.1,an1:12.2,an2:12.3}]
    Returns:
        name (str): The name of the tag (e.g., "TAG1").
        anchor_distance_list (dict): A dictionary of anchors and their values (e.g., {"an0": 12.1, "an1": 12.2, "an2": 12.3}).
    """
    try:
        # Match the message format using a regular expression
        match = re.match(r"\[TAG(\d+):\{(.+)\}\]", message)
        if not match:
            raise ValueError("Message format is invalid")
        
        # Extract the tag ID and anchor data
        tag_name = f"TAG{match.group(1)}"
        anchor_data = match.group(2)

        anchor_distance_list = {}
        for anchor in anchor_data.split(","):               #pytago
            anchor_name, hypotenuse_str = anchor.split(":", 1)
            hypotenuse = float(hypotenuse_str.strip())
            base = math.sqrt(max(hypotenuse**2 - height**2, 0))
            anchor_distance_list[anchor_name.strip()] = round(base, 2)
            print(anchor_distance_list[anchor_name.strip()])

        return tag_name, anchor_distance_list
    except Exception as e:
        print(f"Error parsing message: {e}")
        return None, None

class MqttConnection:
    def __init__(self, username, key, host, port, feed_names, tag_modules):
        self.username = username
        self.key = key
        self.host = host
        self.port = port
        self.feed_names = feed_names  # Accept a list of feed names
        self.topics = [f'{self.username}/feeds/{feed_name}' for feed_name in self.feed_names]  # Generate topics
        self.client = mqtt.Client()
        self.tag_modules = tag_modules
        self.connected = False
        
        # Set up callbacks
        self.client.on_connect = self.on_connect
        self.client.on_message = self.on_message

        # Connect to Adafruit IO
        print('Connecting to Adafruit IO...')
        self.client.username_pw_set(self.username, self.key)
        self.client.connect(self.host, self.port, 60)
        self.client.loop_start()
        
        # Wait for connection
        while not self.connected:
            print("Waiting for MQTT connection...")
            time.sleep(1)

    def on_connect(self, client, userdata, flags, rc):
        if rc == 0:
            print('Connected successfully')
            for topic in self.topics:
                client.subscribe(topic)
                print(f'Subscribed to topic: {topic}')
            self.connected = True
        else:
            print(f'Connection failed with code {rc}')

    def on_message(self, client, userdata, msg):
        # Check if the message is from T2B_distances topic
        if msg.topic != self.topics[0]:
            return None
        
        print(f'Received message: {msg.payload.decode()} on topic {msg.topic}')
        
        # Parse the message and update the tag module
        tag_name, anchor_distance_list = parse_mqtt_message(msg.payload.decode())
        if tag_name and anchor_distance_list:
            if all(value==0 for value in anchor_distance_list.values()):
                print(f"Tag {tag_name} has no distance data")
                return None
            
            # Find the corresponding tag module
            tag_module = next((tag for tag in self.tag_modules if tag.name == tag_name), None)
            tag_module.update(name = tag_name, anchor_distance_list = anchor_distance_list)
            tag_module.calculate_position()
            tag_module.active = True
            tag_module.last_update = time.time()
            tag_module.current_update = True

    def publish(self, message):
        """Publish a message to the MQTT topic."""
        self.client.publish(self.topics[1], message)
        print(f'Published message: {message}')