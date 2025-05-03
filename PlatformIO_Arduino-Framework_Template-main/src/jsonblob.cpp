#include "jsonblob.h"
#include "../project_config.h"

String local_ip = "";
String jsonBlobTask(void *pvParameters) {
    while (local_ip == "") {
        if (WiFi.status() != WL_CONNECTED) {
            Serial.println("WiFi not connected!");
            vTaskDelay(1000 / portTICK_PERIOD_MS);
            continue;
        }
        Serial.println("Waiting for local IP...");
        String url = "https://jsonblob.com/api/jsonBlob/1364243377205469184";
        WiFiClientSecure client;
        client.setInsecure();
        HTTPClient http;
        http.begin(client, url);
        http.addHeader("Content-Type", "application/json");
        http.addHeader("Accept", "application/json");
        int httpCode = http.GET();
        Serial.println("begin");
        if (httpCode == 200) {
            String payload = http.getString();
            StaticJsonDocument<256> doc;
            DeserializationError error = deserializeJson(doc, payload);
            if (!error && doc.containsKey("local_ip")) {
                Serial.println("Local IP found in JSON blob: " + doc["local_ip"].as<String>());
                local_ip = doc["local_ip"].as<String>();
                return local_ip;
            }
        } else {
            Serial.println("Failed to connect to JSON blob: " + String(httpCode));
            local_ip = "";
            return local_ip;
        }
        http.end();
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }
    vTaskDelete(NULL);
}