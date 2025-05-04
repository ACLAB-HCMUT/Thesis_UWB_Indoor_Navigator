import time
import requests
import json
import socket
import subprocess
from pathlib import Path
from mqtt_connection import MqttConnection
from tag import Tag
from anchor import Anchor
from mongoDB_connection import MongoDBConnection

ADAFRUIT_IO_USERNAME = 'aclab241'
ADAFRUIT_IO_KEY = ''
MOSQUITTO_PATH = 'C:\Program Files\mosquitto'

MQTT_HOST = '127.0.0.1'
MQTT_PORT = 1883
FEED_NAMES = ['T2B_distances', 'coordinate', 'edit_anchors']

# Prepare global variables
tag_list = []
anchor_list = []
room_corner_list = [
    Anchor(id=0, name="C0", x=0, y=0, distance_to_tag=None),
    Anchor(id=1, name="C1", x=10.39, y=0, distance_to_tag=None),
    Anchor(id=2, name="C2", x=10.39, y=7.99, distance_to_tag=None),
    Anchor(id=3, name="C3", x=0, y=7.99, distance_to_tag=None),
]

mongoDB_connection = None
mqtt_connection = None

# Initialize Mosquitto broker
def find_and_run_bat(mosquitto_path, bat_filename="run_mosquitto.bat"):
    try:
        # Check if Mosquitto is already running
        result = subprocess.run(['tasklist'], capture_output=True, text=True)
        if 'mosquitto.exe' in result.stdout:
            print("Mosquitto is already running.")
            return
    except Exception as e:
        print(f"Error checking Mosquitto process: {e}")
        return
    
    bat_file = next(Path('.').rglob(bat_filename), None)
    if not bat_file:
        print(f"{bat_filename} not found.")
        return

    result = subprocess.run([str(bat_file), mosquitto_path], shell=True)
    if result.returncode == 0:
        print(f"Successfully ran {bat_filename}.")
    else:
        print(f"Failed to run {bat_filename}. Return code: {result.returncode}")

def load_data_from_db(only_anchors = False):
    devices = mongoDB_connection.fetch_devices()
    
    if devices and only_anchors:
        anchor_list.clear()
        for device in devices:
            if device["device_type"] == 1:
                anchor_module = Anchor(id=device["id"], name=device["name"], x=device["position"][0], y=device["position"][1])
                anchor_list.append(anchor_module)
        return
    
    if devices:
        for device in devices:
            if device["device_type"] == 1:
                anchor_module = Anchor(id=device["id"], name=device["name"], x=device["position"][0], y=device["position"][1])
                anchor_list.append(anchor_module)
            elif device["device_type"] == 0:
                tag_module = Tag(tag_id=device["id"], name=device["name"], position=device["position"])
                tag_list.append(tag_module)

    else:
        print("No devices found in the database.")
    return

def update_data_on_db(module):
    if module.name.startswith("TAG") and module.tag_id:
        device_id = tag_module.tag_id
        x, y = tag_module.position
        device_type = 0
        mongoDB_connection.update_device(device_id, m_to_dm(x), m_to_dm(y), device_type)
    elif module.name.startswith("B"):
        name = module.name
        device_id = module.id
        x, y = module.x, module.y
        device_type = 1
        if (module.current_update_method == "Update") and module.id:
            mongoDB_connection.update_device(device_id, m_to_dm(x), m_to_dm(y), device_type)    
        elif (module.current_update_method == "Create"):
            response_data = mongoDB_connection.create_device(name, device_type)
            if response_data:
                mongoDB_connection.update_device(response_data["_id"], m_to_dm(x), m_to_dm(y), device_type)
        elif (module.current_update_method == "Delete") and module.id :
            mongoDB_connection.delete_device(device_id)
    return
    


# m to dm convertor
def m_to_dm(meters):
    return meters * 10

# get local ip address
def get_local_ip():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Doesn't have to be reachable
        s.connect(('10.255.255.255', 1))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'
    finally:
        s.close()
    return ip

# Update the JSON blob with the public IP address
def update_to_json_blob(local_ip):
    blob_id = '1364243377205469184'
    url = f'https://jsonblob.com/api/jsonBlob/{blob_id}'
    
    # Your new JSON data
    data = {
        "local_ip": local_ip,
        "username": ADAFRUIT_IO_USERNAME,
        "password": ADAFRUIT_IO_KEY
    }
    
    # Send the PUT request
    response = requests.put(
        url,
        headers={
            'Content-Type': 'application/json',
            'Accept': 'application/json'
        },
        data=json.dumps(data)
    )
    
    # Check the response
    if response.status_code == 200:
        print("JSON Blob updated successfully.")
        print("Updated data:", response.json())
    elif response.status_code == 404:
        print("Blob not found. Please check the Blob ID.")
    else:
        print(f"Failed to update JSON Blob. Status code: {response.status_code}")
        print("Response:", response.text)

# Main function
try:
    #Set up and public ip address and mqtt connection to JsonBlob
    local_ip = get_local_ip()
    base_url = f'http://{local_ip}:3000/device'
    update_to_json_blob (local_ip)
    
    # Start Mosquitto broker
    find_and_run_bat(MOSQUITTO_PATH, "run_mosquitto.bat")
    
    # Set up external connections
    mongoDB_connection = MongoDBConnection(base_url)
    
    # Set up id for each module
    load_data_from_db()
    
    mqtt_connection = MqttConnection(
        username=ADAFRUIT_IO_USERNAME,
        key=ADAFRUIT_IO_KEY,
        host=local_ip,
        port=MQTT_PORT,
        feed_names=FEED_NAMES,
        tag_modules=tag_list,
        anchor_modules=anchor_list
    )
    
    # Add anchors to the tag module
    for anchor in anchor_list:
        for tag_module in tag_list:
            tag_module.add_anchor(anchor)
        mqtt_connection.publish(f"Name: {anchor.name}; Coordinate: {m_to_dm(anchor.x)} {m_to_dm(anchor.y)}; Device_type: 1")
        update_data_on_db(anchor)
        # time.sleep(1)

    while True:
        for tag_module in tag_list:
            if tag_module.active:
                tag_module.check_active()
                if tag_module.active == False:
                    mqtt_connection.publish(f"Name: {tag_module.name}; Coordinate: {m_to_dm(tag_module.position[0])} {m_to_dm(tag_module.position[1])}; Device_type: 0; Location: {tag_module.location_status}; Status: {tag_module.active}")
            if tag_module.current_update:
                # Check if the tag is inside the anchor network
                tag_module.define_tag_location_status(room_corner_list)
                mqtt_connection.publish(f"Name: {tag_module.name}; Coordinate: {m_to_dm(tag_module.position[0])} {m_to_dm(tag_module.position[1])}; Device_type: 0; Location: {tag_module.location_status}; Status: {tag_module.active}")
                update_data_on_db(tag_module)
                tag_module.reset()
                
        for anchor_module in anchor_list:
            if anchor_module.current_update_method:
                update_data_on_db(anchor_module)
                anchor_module.reset_htpps_method()
                load_data_from_db(True)
        time.sleep(1)  # Keep the program alive
            
except KeyboardInterrupt:
    print("Exiting...")