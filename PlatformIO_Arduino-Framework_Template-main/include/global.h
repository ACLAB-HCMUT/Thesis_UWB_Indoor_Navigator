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
#include <M5Stack.h>
#include "WiFiUdp.h"
#include <NTPClient.h>
#include <string.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>

//declare internal libraries
#include "wifi_support.h"
#include "server_support.h"
#include "mqtt_support.h"
// #include "uwb_support.h"
#include "jsonblob.h"

//declare global variables
extern int mqttConnectedSignal;
extern String local_ip;

#endif