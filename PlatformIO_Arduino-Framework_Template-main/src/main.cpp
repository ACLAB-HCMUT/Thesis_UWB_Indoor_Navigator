#include "global.h"
#include <M5Stack.h>
#include <Adafruit_NeoPixel.h>

// Define the NeoPixel data pin and the number of pixels
#define PIN_NEOPIXEL 27  // GPIO 27 on M5Stack Atom Lite
#define NUMPIXELS 1      // Number of NeoPixels (only 1 on M5Stack Atom Lite)

// Create a NeoPixel object
Adafruit_NeoPixel pixels(NUMPIXELS, PIN_NEOPIXEL, NEO_GRB + NEO_KHZ800);
int mqttConnectedSignal = 0;
String DATA  = " ";  // Used to store distance data
int UWB_MODE = 0;    // Used to set UWB mode

int UWB_T_UI_NUMBER_2 = 0;  // flag bit
int UWB_T_UI_NUMBER_1 = 0;
int UWB_T_NUMBER      = 0;
int UWB_B_NUMBER      = 0;
int DELAY             = 0;

hw_timer_t *timer   = NULL;
int timer_flag      = 0;
int base_flag       = 0;
uint32_t timer_data = 0;
static void IRAM_ATTR Timer0_CallBack(void);

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
                Serial2.print(DELAY);  // Output base station ID to serial
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
    xTaskCreate(mqttTask, "MQTTTask", 4096, NULL, 1, NULL);
}

void loop() {
    M5.update();

    DATA = Serial2.readString();
    Serial.println(DATA);
    delay(50);
    
    if(DATA.indexOf("B0") != -1){
        publishCoordinate(DATA);
    }
}
