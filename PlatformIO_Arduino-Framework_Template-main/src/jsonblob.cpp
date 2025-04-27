#include "jsonblob.h"

void jsonBlobTask() {
    while (local_ip == "") {
        Serial.println("Waiting for local IP...");
        String url = "https://jsonblob.com/api/jsonBlob/" + JSONBLOB_ID;
        HTTPClient http;
        http.begin(url);
        http.addHeader("Content-Type", "application/json");
        http.addHeader("Accept", "application/json");
        int httpCode = http.GET();
        String payload;
        if (httpCode == 200) {
            String payload = http.getString();
            StaticJsonDocument<256> doc;
            DeserializationError error = deserializeJson(doc, payload);
            if (!error && doc.containsKey("local_ip")) {
                Serial.println("Local IP found in JSON blob: " + doc["local_ip"].as<String>());
                local_ip = doc["local_ip"].as<String>();
            }
        } else {
            Serial.println("Failed to connect to JSON blob: " + String(httpCode));
            local_ip = "";
        }
        http.end();
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }
    vTaskDelete(NULL);
}