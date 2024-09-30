#ifndef MQTT_SUPPORT_H
#define MQTT_SUPPORT_H

#include "global.h"

#define AIO_SERVER "io.adafruit.com"
#define AIO_SERVERPORT 1883
#define AIO_USERNAME "aclab241"
#define AIO_KEY "aio_vgIF36pDKlW42rjNwdkYCgzuuYIw"

void mqttTask(void *pvParameters);
void publishCoordinate(void *pvParameters);
extern WiFiClient client;
extern Adafruit_MQTT_Client mqtt;

#endif