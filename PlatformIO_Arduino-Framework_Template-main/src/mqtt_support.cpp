#include "mqtt_support.h"
#include "../project_config.h"

void mqttTask(Adafruit_MQTT_Client* mqtt){
    Serial.println("MQTT Task started");
    // vTaskDelay(5000 / portTICK_PERIOD_MS);
    if (mqtt->connect()){
        Serial.println("MQTT Connected");
    } else {
        Serial.println("MQTT Connection Failed");
    }

    while (!mqtt->connected()){
        Serial.println("Reconnecting to MQTT");
        mqtt->connect();
        delay(1000);
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }

    Serial.println("MQTT Connected");
    // vTaskDelete(NULL);
}

float randomFloat (float minValue, float maxValue){
    float random = ((float) rand()) / (float) RAND_MAX;
    return minValue + random * (maxValue - minValue);
}

void publishCoordinate(Adafruit_MQTT_Client* mqtt, Adafruit_MQTT_Publish coordinate, String coordinateValue){
    if (mqtt->connected()){
        coordinate.publish(coordinateValue.c_str());
        Serial.print("Publish coordinate value: ");
        Serial.print(coordinateValue);
        Serial.println();
    } else {
        Serial.println("MQTT Disconnected");
    }
}