#include "global.h"
#include <M5Stack.h>

String DATA = " ";

int UWB_MODE = 0; // 0: Tag, 1: Base station
int UWB_T_NUMBER = 0; // Tag number
int UWB_B_NUMBER = 0; // Base station number
int TIME_SLOT = 1000;
float distancesList[4] = {0.0, 0.0, 0.0, 0.0};
int distanceNumber = 0; // number of available distances
float BasePosition[3][2] = {{0,0}, {0,10}, {10,0}};

void extractDistance (String data) {
    for (int i = 0; i < 4; i++) {
        String tagInfo = "an" + String(i) + ":";
        int startIndex = data.indexOf(tagInfo);

        int endIndex = data.indexOf("m", startIndex);
        String distance = data.substring(startIndex + tagInfo.length(), endIndex);
        if (startIndex == -1 || endIndex == -1) continue;
        distancesList[i] = distance.toFloat();
        distanceNumber++;
    }
}

void UWB_readString() {
    unsigned long currentTime = millis();
    if ((currentTime / TIME_SLOT) % 4 == UWB_T_NUMBER)
    {
        // Serial2.write("AT+RST\r\n");
        // delay(100);
        Serial2.write("AT+anchor_tag=0\r\n");
        delay(100);
        Serial2.write("AT+interval=5\r\n");
        delay(100);
        Serial2.write("AT+switchdis=1\r\n");
        delay(100);
        
        Serial.print("\nDistance: ");
        DATA = Serial2.readString();
        // Serial.print (DATA);
        extractDistance (DATA);
        DATA = "";
        int tmpIndex = 0;
        while (tmpIndex < 4) {
            Serial.print(distancesList[tmpIndex]);
            Serial.print(" ");
            tmpIndex++;
        }

        Serial2.write("AT+RST\r\n");
        delay(100);
    }
}

void UWB_setupmode() {
    switch (UWB_MODE) {
        case 0:
            delay(50);
            Serial2.write("AT+RST\r\n");
            DATA = "";
            Serial.println("UWB Tag mode setup complete.");
            break;
        case 1:
            for (int b = 0; b < 2; b++) {
                delay(50);
                Serial2.write("AT+anchor_tag=1,");
                Serial2.print (UWB_B_NUMBER);
                Serial2.write("\r\n");
                delay(1);
                delay(50);
                if (b == 0) {
                    Serial2.write("AT+RST\r\n");
                }
            }
            DATA = "";
            Serial.println("UWB Base station mode setup complete.");
            break;
    }
}

// void calculateTagPosition () {
//     if (distanceIndex < 3) return;
    
// }

void UWBTask () {
    M5.begin();
    M5.Power.begin();
    Serial2.begin(115200, SERIAL_8N1, 32, 26);
    UWB_setupmode();
    delay(1000);
    while (1) {
        if (UWB_MODE == 1) break;
        UWB_readString();
        // calculateTagPosition();

        // reset distance list
        for (int i = 0; i < 4; i++) {
            distancesList[i] = 0.0;
        }
        distanceNumber = 0;
    }
}

void setup()
{
    // xTaskCreate(wifiTask, "WiFiTask", 4096, NULL, 1, NULL);
    // xTaskCreate(mqttTask, "MQTTTask", 4096, NULL, 1, NULL);
    UWBTask();
}

void loop()
{
    // Nothing to do here, FreeRTOS tasks handle the work
}