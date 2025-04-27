#include "jsonblob.h"

String getJsonBlob() {
    String url = "https://jsonblob.com/api/jsonBlob/" + JSONBLOB_ID;
    HTTPClient http;
    http.begin(url);
    http.addHeader("Content-Type", "application/json");
    http.addHeader("Accept", "application/json");
    int httpCode = http.GET();
    String payload;
    String local_ip = "";
    if (httpCode == 200) {
        String payload = http.getString();
        StaticJsonDocument<256> doc;
        DeserializationError error = deserializeJson(doc, payload);
        if (!error && doc.containsKey("local_ip")) {
            local_ip = doc["local_ip"].as<String>();
        }
    } else {
        local_ip = "";
    }
    http.end();
    return local_ip;
}

int main(){
    // Initialize WiFi and MQTT connections
    wifiTask(NULL);
    mqttTask(NULL);

    // Get JSON blob data
    String jsonData = getJsonBlob();
    Serial.println(jsonData);

    // Publish coordinate data
    // publishCoordinate("123.456,789.012");

    return 0;
}