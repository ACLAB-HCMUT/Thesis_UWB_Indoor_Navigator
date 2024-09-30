#ifndef MQTT_SUPPORT_H
#define MQTT_SUPPORT_H

#include "global.h"

#define AIO_SERVER "io.adafruit.com"
#define AIO_SERVERPORT 1883
#define AIO_USERNAME "your_username"
#define AIO_KEY "your_key"

void mqttTask(void *pvParameters);
void publishCoordinate(void *pvParameters);
extern WiFiClient client;
extern Adafruit_MQTT_Client mqtt;

#endif