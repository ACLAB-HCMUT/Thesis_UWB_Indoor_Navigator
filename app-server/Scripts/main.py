import time

from mqtt_connection import MqttConnection
from tag import Tag
from anchor import Anchor
from mongoDB_connection import MongoDBConnection

ADAFRUIT_IO_USERNAME = ''
ADAFRUIT_IO_KEY = ''

MQTT_HOST = 'io.adafruit.com'
MQTT_PORT = 1883
FEED_NAMES = ['T2B_distances', 'coordinate']

BASE_URL = 'http://localhost:3000/device'

# Prepare global variables
tag_list = [
    Tag(name="TAG1"),
    Tag(name="TAG2"),
    Tag(name="TAG3"),
]
anchor_list = [
    Anchor(id=0, name="B0", x=6.57, y=0, distance_to_tag=None),
    Anchor(id=1, name="B1", x=3.57, y=0.73, distance_to_tag=None),
    Anchor(id=2, name="B2", x=6.57, y=7.78, distance_to_tag=None),
]
mongoDB_connection = None
mqtt_connection = None

def load_data_from_db():
    devices = mongoDB_connection.fetch_devices()
    if devices:
        for device in devices:
            device_id = device["id"]
            device_name = device["name"]
            
            if device_name.startswith("TAG"):
                tag_module = next ((tag for tag in tag_list if tag.name == device_name), None)
                if tag_module:
                    tag_module.tag_id = device_id
                    tag_module.name = device_name
                    tag_module.position = None
                    
            elif device_name.startswith("B"):
                anchor_module = next ((anchor for anchor in anchor_list if anchor.name == device_name), None)
                if anchor_module:
                    anchor_module.id = device_id
                    anchor_module.name = device_name
    else:
        print("No devices found in the database.")
    return

def update_data_on_db(module):
    if module.name.startswith("TAG") and module.tag_id:
        device_id = tag_module.tag_id
        x, y = tag_module.position
        device_type = 0
        mongoDB_connection.update_device(device_id, m_to_dm(x), m_to_dm(y), device_type)
    elif module.name.startswith("B") and module.id:
        device_id = module.id
        x, y = module.x, module.y
        device_type = 1
        mongoDB_connection.update_device(device_id, m_to_dm(x), m_to_dm(y), device_type)    
    
    return
    
def define_tag_location_status(tag_position, anchor_list):
    """
    Check if the tag is inside the polygon formed by the anchors using the ray-casting algorithm.
    
    :param tag_position: Tuple (x, y) representing the tag's position.
    :param anchor_list: List of Anchor objects with x and y coordinates.
    :return: True if the tag is inside the anchor network, False otherwise.
    """
    if not tag_position or len(anchor_list) < 3:
        # A polygon requires at least 3 anchors
        return False

    x, y = tag_position
    n = len(anchor_list)
    inside = False

    # Loop through each edge of the polygon
    for i in range(n):
        # Get the current and next anchor
        anchor1 = anchor_list[i]
        anchor2 = anchor_list[(i + 1) % n]  # Wrap around to the first anchor

        x1, y1 = anchor1.x, anchor1.y
        x2, y2 = anchor2.x, anchor2.y

        # Check if the ray intersects with the edge
        if ((y1 > y) != (y2 > y)) and (x < (x2 - x1) * (y - y1) / (y2 - y1) + x1):
            inside = not inside

    if inside:
        return "In Room"
    else:
        return "Out of Room"

# m to dm convertor
def m_to_dm(meters):
    return meters * 10

# Main function
try:
    # Set up external connections
    mongoDB_connection = MongoDBConnection(BASE_URL)
    mqtt_connection = MqttConnection(
        username=ADAFRUIT_IO_USERNAME,
        key=ADAFRUIT_IO_KEY,
        host=MQTT_HOST,
        port=MQTT_PORT,
        feed_names=FEED_NAMES,
        tag_modules=tag_list
    )
    
    # Set up id for each module
    load_data_from_db()
    
    # Add anchors to the tag module
    for anchor in anchor_list:
        for tag_module in tag_list:
            tag_module.add_anchor(anchor)
        mqtt_connection.publish(f"Name: {anchor.name}; Coordinate: {m_to_dm(anchor.x)} {m_to_dm(anchor.y)}; Device_type: 1")
        update_data_on_db(anchor)
        time.sleep(1)

    while True:
        for tag_module in tag_list:
            if tag_module.position:
                # Check if the tag is inside the anchor network
                tag_location_status = define_tag_location_status(tag_module.position, anchor_list)
                mqtt_connection.publish(f"Name: {tag_module.name}; Coordinate: {m_to_dm(tag_module.position[0])} {m_to_dm(tag_module.position[1])}; Device_type: 0; Location: {tag_location_status}")
                update_data_on_db(tag_module)
                tag_module.reset()
        time.sleep(1)  # Keep the program alive
            
except KeyboardInterrupt:
    print("Exiting...")