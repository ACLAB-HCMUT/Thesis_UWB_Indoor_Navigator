#include "global.h"
#include <M5Stack.h>

void setup()
{
    xTaskCreate(jsonBlobTask, "JsonBlobTask", 4096, NULL, 1, NULL);
    xTaskCreate(wifiTask, "WiFiTask", 4096, NULL, 1, NULL);
    xTaskCreate(mqttTask, "MQTTTask", 4096, NULL, 1, NULL);
    xTaskCreate(uwbTask, "UWBTask", 4096, NULL, 1, NULL);
}

void loop()
{
    // Nothing to do here, FreeRTOS tasks handle the work
}