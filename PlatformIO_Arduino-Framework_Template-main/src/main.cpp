#include "global.h"

void setup(){
  Serial.begin(115200);
  // pinMode(ledPin, OUTPUT);

  xTaskCreate(wifiTask, "WiFiTask", 4096, NULL, 1, NULL);
  xTaskCreate(mqttTask, "MQTTTask", 4096, NULL, 1, NULL);
  xTaskCreate(publishCoordinate, "PublishCoordinate", 4096, NULL, 1, NULL);
  // xTaskCreate(serverTask, "ServerTask", 8192, NULL, 1, NULL);
}

void loop(){
  // Nothing to do here, FreeRTOS tasks handle the work
}