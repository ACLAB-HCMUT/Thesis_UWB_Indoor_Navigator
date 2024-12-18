#ifndef MQTT_SUPPORT_H
#define MQTT_SUPPORT_H

#include "global.h"

void mqttTask(void *pvParameters);
void publishCoordinate(String data);
extern WiFiClient client;
extern Adafruit_MQTT_Client mqtt;

#endif