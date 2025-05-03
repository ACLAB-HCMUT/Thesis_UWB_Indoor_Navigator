#ifndef MQTT_SUPPORT_H
#define MQTT_SUPPORT_H

#include "global.h"

void mqttTask(Adafruit_MQTT_Client* mqtt);
void publishCoordinate(Adafruit_MQTT_Client* mqtt, Adafruit_MQTT_Publish coordinate, String coordinateValue);

#endif