#ifndef GLOBAL_H
#define GLOBAL_H

//declare all external libraries
#include "WiFi.h"
#include "ESPAsyncWebServer.h"
#include "SPIFFS.h"
#include "DHT20.h"
#include "freertos/FreeRTOS.h"
#include "freertos/task.h"
#include "Adafruit_MQTT.h"
#include "Adafruit_MQTT_Client.h"

//declare internal libraries
#include "wifi_support.h"
#include "server_support.h"
#include "mqtt_support.h"

//declare global variables
extern int mqttConnectedSignal;


#endif