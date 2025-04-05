import paho.mqtt.client as mqtt
import re
import time

from anchor import Anchor

def parse_mqtt_message(message):
    """
    Parse the MQTT message and return the tag ID and anchor list.
    Message format: [tag1:{an0:12.1,an1:12.2,an2:12.3}]
    Returns:
        tag_id (str): The tag ID (e.g., "tag1").
        anchor_distance_list (dict): A dictionary of anchors and their values (e.g., {"an0": 12.1, "an1": 12.2, "an2": 12.3}).
    """
    try:
        # Match the message format using a regular expression
        match = re.match(r"\[tag(\d+):\{(.+)\}\]", message)
        if not match:
            raise ValueError("Message format is invalid")
        
        # Extract the tag ID and anchor data
        tag_id = int(re.search(r"\d+", match.group(1)).group())  # Extract the tag ID as an integer
        anchor_data = match.group(2)

        anchor_distance_list = {}
        for anchor in anchor_data.split(","):
            key, value = anchor.split(":")
            key = int(re.search(r"\d+", key).group())  # Extract the anchor ID as an integer
            anchor_distance_list[key] = float(value)

        return tag_id, anchor_distance_list
    except Exception as e:
        print(f"Error parsing message: {e}")
        return None, None

class MqttConnection:
    def __init__(self, username, key, host, port, feed_names, tag_module):
        self.username = username
        self.key = key
        self.host = host
        self.port = port
        self.feed_names = feed_names  # Accept a list of feed names
        self.topics = [f'{self.username}/feeds/{feed_name}' for feed_name in self.feed_names]  # Generate topics
        self.client = mqtt.Client()
        self.tag_module = tag_module
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
        tag_id, anchor_distance_list = parse_mqtt_message(msg.payload.decode())
        if tag_id and anchor_distance_list:
            self.tag_module.update(tag_id, anchor_distance_list)

        self.tag_module.calculate_position()

    def publish(self, message):
        """Publish a message to the MQTT topic."""
        self.client.publish(self.topics[1], message)
        print(f'Published message: {message}')