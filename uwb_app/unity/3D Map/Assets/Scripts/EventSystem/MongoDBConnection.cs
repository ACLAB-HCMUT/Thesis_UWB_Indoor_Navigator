using NUnit.Framework;
using System.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using UnityEngine;
using UnityEngine.Networking;

public class MongoDBConnection : MonoBehaviour
{
    private string baseURL = "http://localhost:3000/device";
    [System.Serializable]
    public class History
    {
        public string _id;
        public float x;
        public float y;
        public string createdAt;
    }
    [System.Serializable]
    public class Device
    {
        public string _id;
        public string name;
        public List<History> histories;
        public string createdAt;
        public string updatedAt;
        public int device_type;
    }
    [System.Serializable]
    public class DeviceList
    {
        public List<Device> devices;
    }
    public async Task<DeviceList> GetAllDevices(string ipAddress)
    {
        if (!string.IsNullOrEmpty(ipAddress))
        {
            baseURL = $"http://{ipAddress}:3000/device";
        }
        string url = $"{baseURL}";
        Debug.Log ("Base URL: " + url);
        using (UnityWebRequest request = UnityWebRequest.Get(url))
        {
            try
            {
                await request.SendWebRequest();
                string jsonResponse = request.downloadHandler.text;
                DeviceList deviceList = JsonUtility.FromJson<DeviceList>("{\"devices\":" + jsonResponse + "}");
                return deviceList;
            }
            catch (System.Exception ex)
            {
                Debug.LogError(ex.Message);
                return null;
            }
        }
    }
}
