#include "global.h"

void setup(){
  Serial.begin(115200);

  xTaskCreate(wifiTask, "WiFiTask", 4096, NULL, 1, NULL);
  xTaskCreate(mqttTask, "MQTTTask", 4096, NULL, 1, NULL);
}

void loop(){
  // Nothing to do here, FreeRTOS tasks handle the work
}