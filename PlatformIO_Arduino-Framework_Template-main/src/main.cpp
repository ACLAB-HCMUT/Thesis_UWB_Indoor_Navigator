#include "global.h"
#include <M5Stack.h>
#include <Adafruit_NeoPixel.h>
#include "../project_config.h"

WiFiClient client;
Adafruit_MQTT_Client* mqtt = nullptr;
Adafruit_MQTT_Publish* coordinate = nullptr;

// Define the NeoPixel data pin and the number of pixels
#define PIN_NEOPIXEL 27  // GPIO 27 on M5Stack Atom Lite
#define NUMPIXELS 1      // Number of NeoPixels (only 1 on M5Stack Atom Lite)

// Create a NeoPixel object
Adafruit_NeoPixel pixels(NUMPIXELS, PIN_NEOPIXEL, NEO_GRB + NEO_KHZ800);
String DATA  = " ";  // Used to store distance data
int UWB_MODE = 0;    // Used to set UWB mode

int UWB_T_UI_NUMBER_2 = 0;  // flag bit
int UWB_T_UI_NUMBER_1 = 0;
int UWB_T_NUMBER      = 2;
int UWB_B_NUMBER      = 0;
int RXDELAY           = 16650;
int MAXTAG            = 3;

hw_timer_t *timer   = NULL;
int timer_flag      = 0;
int base_flag       = 0;
uint32_t timer_data = 0;
static void IRAM_ATTR Timer0_CallBack(void);

float distancesList[3] = {0.0, 0.0, 0.0};
int distanceNumber = 0; // number of available distances
float tagPos[2] = {0.0, 0.0};
float basePos[3][2] = {{6.57,0}, {3.57,0}, {6.57,7.78}};

void extractDistance (String data) {
    for (int i = 0; i < 3; i++) {
        String tagInfo = "B" + String(i) + ":";
        int startIndex = data.indexOf(tagInfo);
        int endIndex;
        if(i < 2)
            endIndex = data.indexOf(",", startIndex);
        else
            endIndex = data.indexOf("}", startIndex);
        String distance = data.substring(startIndex + tagInfo.length(), endIndex);
        // Serial.print(distance);
        if (startIndex == -1 || endIndex == -1) continue;
        // distancesList[i] = 0.867*(distance.toFloat()) - 0.146;
        distancesList[i] = (distance.toFloat());
        distanceNumber++;
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
        // Serial.print(B[i]);
        // Serial.print ("\n");      
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
// Display and data clear
void UWB_clear() {
    if (Serial2.available()) {
        delay(3);
        DATA = Serial2.readString();
    }
    DATA       = "";
    timer_flag = 0;
    timer_data = 0;

    // Clear serial output (no need to clear a display)
    Serial.println("Data cleared.");
}

// AT command setup
void UWB_setupmode() {
    switch (UWB_MODE) {
        case 0:
            for (int b = 0; b < 2; b++) {  // Repeat twice to stabilize the connection
                delay(50);
                Serial2.write("AT+anchor_tag=0,");  // Set up the Tag
                Serial2.print(UWB_T_NUMBER);  // Output base station ID to serial
                Serial2.write(",");  // Set up the Tag
                Serial2.print(RXDELAY);  // Output base station ID to serial
                Serial2.write(",");  // Set up the Tag
                Serial2.print(MAXTAG);  // Output base station ID to serial
                Serial2.write("\r\n");
                Serial.println("Set up Tag");
                delay(50);
                Serial.println("Start measuring");
                delay(50);
                if (b == 0) {
                    Serial2.write("AT+RST\r\n");  // RESET
                    Serial.println("Reset");
                }
            }
            UWB_clear();
            Serial.println("UWB Tag mode setup complete.");
            break;
        case 1:
            for (int b = 0; b < 2; b++) {
                delay(50);
                Serial2.write("AT+anchor_tag=1,");  // Set the base station
                Serial2.print(UWB_B_NUMBER);  // Output base station ID to serial
                Serial2.write("\r\n");
                delay(1);
                delay(50);
                if (b == 0) {
                    Serial2.write("AT+RST\r\n");
                }
            }
            UWB_clear();
            Serial.println("UWB Base station mode setup complete.");
            break;
    }
}



// Timer initialization
void UWB_Timer() {
    timer = timerBegin(0, 80, true);  // Timer setting
    timerAttachInterrupt(timer, Timer0_CallBack, true);
    timerAlarmWrite(timer, 1000000, true);
    timerAlarmEnable(timer);
}

static void IRAM_ATTR Timer0_CallBack(void)  // Timer function
{
    if (timer_flag == 1) {
        timer_data++;
        if (timer_data == 4294967280) {
            timer_data = 1;
        }
    } else {
        timer_data = 0;
    }
}

// Setup and initialize tasks
void setup() {
    M5.begin();
    M5.Power.begin();
    pixels.begin();
  
    // // Turn off the NeoPixel
    // pixels.clear();
    // pixels.show(); 
    Serial.begin(115200);
    Serial2.begin(115200, SERIAL_8N1, 32, 26);  // Use RX 26, TX 32 for Serial2
    delay(100);
    UWB_setupmode();
    UWB_Timer();
    Serial2.write("AT+RST\r\n");
    xTaskCreate(wifiTask, "WiFiTask", 4096, NULL, 1, NULL);
    String local_ip = jsonBlobTask(NULL);
    // xTaskCreate(mqttTask, "MQTTTask", 4096, NULL, 1, NULL);

    mqtt = new Adafruit_MQTT_Client(&client, local_ip.c_str(), AIO_SERVERPORT, AIO_USERNAME, AIO_KEY);
    coordinate = new Adafruit_MQTT_Publish(mqtt, AIO_USERNAME "/feeds/T2B_distances");   
    mqttTask(mqtt);
    
}

void loop() {
    M5.update();

    DATA = Serial2.readString();
    Serial.println(DATA);
    // delay(50);
    
    if(DATA.indexOf("B0") != -1){

        // DATA = "[TAG2:{B0:4.74,B1:5.18,B2:6.20}]";
        extractDistance(DATA);
        // calculateTagPosition();
        // delay(50000);
        if(distancesList[0] != 0 & distancesList[1] != 0 & distancesList[2] != 0)
            publishCoordinate(mqtt, *coordinate, DATA.c_str());
    }
    for (int i = 0; i < 3; i++) {
        distancesList[i] = 0.0;
    }
    tagPos[0] = 0.0;
    tagPos[1] = 0.0;
    distanceNumber = 0;
    delay(1000);
}
