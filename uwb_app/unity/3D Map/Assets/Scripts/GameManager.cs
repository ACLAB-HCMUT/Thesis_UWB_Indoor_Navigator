using NUnit.Framework;
using NUnit.Framework.Constraints;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using TMPro;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.PlayerLoop;

public class GameManager : MonoBehaviour
{
    [SerializeField] private TMP_InputField consoleInputField;
    public MongoDBConnection mongoDBConnection = null;
    public MqttConnection mqttConnection;

    private List<GameObject> spawnedDevices = new List<GameObject>();
    private MongoDBConnection.DeviceList deviceList;
    public GameObject tagPrefab;
    public GameObject basePrefab;

    public string ipAddress;


    private async void Start()
    {
        
        while (mongoDBConnection == null)
        {
            await Task.Delay(1000);
            Debug.Log("Waiting for MongoDBConnection");
            AddUiMessage("Waiting for MongoDBConnection");
            mongoDBConnection = FindFirstObjectByType<MongoDBConnection>();
        }
        await SpawnDevices();
        HandleMqttConnection();
    }

    private void Update()
    {
    }

    //private void OnDestroy()
    //{
        //if (mqttConnection != null)
        //{
        //    mqttConnection.OnMessageReceived -= HandleMessageReceived;
        //}
    //}



    private async Task SpawnDevices()
    {
        foreach (var device in spawnedDevices)
        {
            Destroy(device);
        }
        spawnedDevices.Clear();

        deviceList = await mongoDBConnection.GetAllDevices(ipAddress);
        if (deviceList == null)
        {
            Debug.LogError("Cannot get device list");
            return;
        }
        foreach (var device in deviceList.devices)
        {
            var latestPos = device.histories.FirstOrDefault();
            if (latestPos == null)
                continue;
            Vector3 position = new Vector3(latestPos.x, 0, latestPos.y);
            GameObject prefabToInstantiate = null;
            if (device.device_type == 0)
            {
                prefabToInstantiate = tagPrefab;
            }
            else
            {
                prefabToInstantiate = basePrefab;
            }
            if (prefabToInstantiate != null)
            {
                GameObject newDevice = Instantiate(prefabToInstantiate, position, Quaternion.identity);
                PlayerBehavior playerBehavior = newDevice.GetComponent<PlayerBehavior>();
                playerBehavior.deviceName = device.name;
                playerBehavior.deviceId = device._id;
                spawnedDevices.Add(newDevice);
            }
        }
    }
    private void HandleMqttConnection()
    {
        //mqttConnection = FindFirstObjectByType<MqttConnection>();
        //if (mqttConnection != null)
        //{
        //    mqttConnection.OnMessageReceived += HandleMessageReceived;
        //}
        //else
        //{
        //    Debug.LogError("MqttConnection not found");
        //    AddUiMessage("MqttConnection not found");
        //}
    }
    public async void HandleMessageReceived(string message)
    {
        AddUiMessage("Received message from gameManager: " + message);
        var parsedData = ParseMessage(message);
        if (!parsedData.HasValue)
        {
            Debug.Log("Cannot parse message");
            AddUiMessage("Cannot parse message");
            return;
        }
        var deviceNewValue = parsedData.Value;
        var matchingDevice = spawnedDevices.FirstOrDefault(spawnedDevices => spawnedDevices.GetComponent<PlayerBehavior>().deviceName == deviceNewValue.name);

        if (matchingDevice != null)
        {
            var playerBehavior = matchingDevice.GetComponent<PlayerBehavior>();
            if (playerBehavior != null)
            {
                playerBehavior.UpdatePos(deviceNewValue.x, deviceNewValue.y);
            }
        }
        else
        {
            Debug.Log("Device not found");
            Debug.Log("Checking new device from MongoDB");
            AddUiMessage("Device not found, checking new device from MongoDB");
            await SpawnDevices();
            return;
        }
    }
    private (string name, float x, float y, int deviceType)? ParseMessage(string message)
    {
        AddUiMessage("Parsing message: " + message);
        var parts = message.Split(';');
        var namePart = parts[0].Split(':')[1].Trim();
        var coordinatePart = parts[1].Split(':')[1].Trim().Split(' ');
        var x = float.Parse(coordinatePart[0]);
        var y = float.Parse(coordinatePart[1]);
        var deviceType = int.Parse(parts[2].Split(':')[1].Trim());
        return (namePart, x, y, deviceType);
    }
    public async void UpdateIPAddress(string newIPAddress)
    {
        ipAddress = newIPAddress;
        await SpawnDevices();
    }
    public void AddUiMessage(string msg)
    {
        if (consoleInputField != null)
        {
            consoleInputField.text += msg + "\n";
        }
    }
}
