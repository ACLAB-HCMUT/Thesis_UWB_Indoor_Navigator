#include "global.h"

String DATA = " ";

int UWB_MODE = 0; // 0: Tag, 1: Base station
int UWB_T_NUMBER = 0; // Tag number
int UWB_B_NUMBER = 0; // Base station number
float distancesList[3] = {0.0, 0.0, 0.0};
int distanceNumber = 0; // number of available distances
float tagPos[2] = {0.0, 0.0};
float basePos[3][2] = {{0,0}, {0,0.9}, {1.6,0}};

String preparePublishMessage (float x, float y) {
    String message = "";
    if (UWB_MODE == 0) {
        message = "Name: TAG" + String (UWB_T_NUMBER);
    } else if (UWB_MODE == 1) {
        message = "Name: BASE" + String (UWB_B_NUMBER);
    }

    message += "; Coordinate X: " + String (x) + " Y: " + String (y);
    timeClient.update();
    message += "; Time: " + timeClient.getFormattedTime();
    return message;
}

void extractDistance (String data) {
    for (int i = 0; i < 4; i++) {
        String tagInfo = "an" + String(i) + ":";
        int startIndex = data.indexOf(tagInfo);

        int endIndex = data.indexOf("m", startIndex);
        String distance = data.substring(startIndex + tagInfo.length(), endIndex);
        if (startIndex == -1 || endIndex == -1) continue;
        distancesList[i] = 4.61*distance.toFloat() + 0.02168;
        distanceNumber++;
    }
}

void UWB_readString() {
    unsigned long currentTime = millis();
    if ((currentTime / 1000) % 4 == UWB_T_NUMBER)
    {
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
        while (tmpIndex < 3) {
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

void calculateTagPosition () {
    // View algorithm here: https://www.sciencedirect.com/science/article/pii/S2665917424000977?via%3Dihub
    float A[distanceNumber - 1][2];
    float B[distanceNumber - 1];

    for (int i = 0; i < distanceNumber - 1; i++) {
        A[i][0] = 2 * (basePos[i][0] - basePos[2][0]);
        A[i][1] = 2 * (basePos[i][1] - basePos[2][1]);
        B[i] = pow(basePos[i][0], 2) - pow(basePos[distanceNumber - 1][0], 2) + pow(basePos[i][1], 2) - pow(basePos[distanceNumber - 1][1], 2) + pow(distancesList[distanceNumber - 1], 2) - pow(distancesList[i], 2);
    }
    float A_inv[2][2];
    float det_A = A[0][0] * A[1][1] - A[0][1] * A[1][0];
    A_inv[0][0] = A[1][1] / det_A;
    A_inv[0][1] = -A[0][1] / det_A;
    A_inv[1][0] = -A[1][0] / det_A;
    A_inv[1][1] = A[0][0] / det_A;

    tagPos[0] = A_inv[0][0] * B[0] + A_inv[0][1] * B[1];
    tagPos[1] = A_inv[1][0] * B[0] + A_inv[1][1] * B[1];
    

    Serial.print ("Tag position: ");
    Serial.print (tagPos[0]);
    Serial.print (" ");
    Serial.println (tagPos[1]);
}

void uwbTask (void *pvParameters) {
    while (mqttConnectedSignal == 0) {
        vTaskDelay(1000 / portTICK_PERIOD_MS);
    }
    M5.begin();
    M5.Power.begin();
    Serial2.begin(115200, SERIAL_8N1, 32, 26);
    UWB_setupmode();
    delay(1000);
    while (1) {
        if (UWB_MODE == 1) break;
        UWB_readString();
        if (distanceNumber > 2) {
            calculateTagPosition();
            String publishMessage = preparePublishMessage (tagPos[0], tagPos[1]);
            publishCoordinate (publishMessage);
        }
        // reset distance list
        for (int i = 0; i < 3; i++) {
            distancesList[i] = 0.0;
        }
        tagPos[0] = 0.0;
        tagPos[1] = 0.0;
        distanceNumber = 0;
    }
}