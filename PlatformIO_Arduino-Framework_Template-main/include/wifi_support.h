#ifndef WIFI_SUPPORT_H
#define WIFI_SUPPORT_H

#include "global.h"

extern const char* ssid;
extern const char* password;

void wifiTask(void *pvParameters);

#endif