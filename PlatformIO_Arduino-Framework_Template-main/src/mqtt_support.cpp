#include "mqtt_support.h"

WiFiClient client;
Adafruit_MQTT_Client mqtt(&client, AIO_SERVER, AIO_SERVERPORT, AIO_USERNAME, AIO_KEY);
Adafruit_MQTT_Publish coordinate = Adafruit_MQTT_Publish(&mqtt, AIO_USERNAME "/feeds/coordinate");

void mqttTask(void *pvParameters){
    vTaskDelay(5000 / portTICK_PERIOD_MS);
    if (mqtt.connect()){
        Serial.println("MQTT Connected");
    } else {
        Serial.println("MQTT Connection Failed");
    }

    while (!mqtt.connected()){
        Serial.println("Reconnecting to MQTT");
        mqtt.connect();
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }

    Serial.println("MQTT Connected");
    mqttConnectedSignal = 1;
    vTaskDelete(NULL);
}

float randomFloat (float minValue, float maxValue){
    float random = ((float) rand()) / (float) RAND_MAX;
    return minValue + random * (maxValue - minValue);
}

void publishCoordinate(String coordinateValue){
    if (mqtt.connected()){
        coordinate.publish(coordinateValue.c_str());
        Serial.print("Publish coordinate value: ");
        Serial.print(coordinateValue);
        Serial.println();
    } else {
        Serial.println("MQTT Disconnected");
        mqttConnectedSignal = 0;
    }
}