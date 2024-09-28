#include "wifi_support.h"

const char* ssid = PROJECT_WIFI_SSID;
const char* password = PROJECT_WIFI_PASSWORD;

void wifiTask(void *pvParameters) {
  Serial.begin(115200);
  WiFi.begin(ssid);
  while (WiFi.status() != WL_CONNECTED) {
    vTaskDelay(1000 / portTICK_PERIOD_MS);
    Serial.println("Connecting to WiFi..");
  }

  Serial.println(WiFi.localIP());
  vTaskDelete(NULL);
}