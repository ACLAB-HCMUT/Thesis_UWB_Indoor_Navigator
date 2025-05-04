import requests

class MongoDBConnection:
    def __init__(self, url):
        self.url = url

    def fetch_devices(self):
        try:
            response = requests.get(self.url)
            if response.status_code == 200:
                data = response.json()
                devices = [
                    {
                        "id": device["_id"],
                        "name": device["name"],
                        "device_type": device["device_type"],
                        "position": [device["histories"][0]["x"], device["histories"][0]["y"]] if device.get("histories") and len(device["histories"]) > 0 else None
                    }
                    for device in data
                ]
                return devices
            else:
                print(f'Failed to fetch data. Status code: {response.status_code}')
        except requests.exceptions.RequestException as e:
            print(f'Error occurred: {e}')
    
    def update_device(self, device_id, x, y, device_type):
        url = f"{self.url}/{device_id}"
        
        payload = {
            "history": {
                "x": x,
                "y": y
            },
            "device_type": device_type
        }
        headers = {"Content-Type": "application/json"}

        try:
            response = requests.patch(url, json=payload, headers=headers)
            if response.status_code == 200:
                print (f"Device {device_id} updated successfully.")
                return response.json()
            else:
                print(f"Failed to update device {device_id}. Status code: {response.status_code}")
                print(f"Response: {response.text}")
        except requests.exceptions.RequestException as e:
            print(f"Error occurred while updating device {device_id}: {e}")
            
    def create_device(self, name, device_type):
        url = self.url
        
        payload = {
            "name": name,
            "device_type": device_type
        }
        headers = {"Content-Type": "application/json"}

        try:
            response = requests.post(url, json=payload, headers=headers)
            if response.status_code == 201:
                print (f"Device {name} created successfully.")
                return response.json()
            else:
                print(f"Failed to create device {name}. Status code: {response.status_code}")
                print(f"Response: {response.text}")
        except requests.exceptions.RequestException as e:
            print(f"Error occurred while creating device {name}: {e}")
            
    def delete_device(self, device_id):
        url = f"{self.url}/{device_id}"
        
        headers = {"Content-Type": "application/json"}

        try:
            response = requests.delete(url, headers=headers)
            if response.status_code == 200:
                print (f"Device {device_id} deleted successfully.")
                return response.json()
            else:
                print(f"Failed to delete device {device_id}. Status code: {response.status_code}")
                print(f"Response: {response.text}")
        except requests.exceptions.RequestException as e:
            print(f"Error occurred while deleting device {device_id}: {e}")