#include "global.h"
#include <M5Stack.h>

String DATA  = " ";  // Used to store distance data
int UWB_MODE = 0;    // Used to set UWB mode

int UWB_T_UI_NUMBER_2 = 0;  // flag bit
int UWB_T_UI_NUMBER_1 = 0;
int UWB_T_NUMBER      = 0;
int UWB_B_NUMBER      = 0;

hw_timer_t *timer   = NULL;
int timer_flag      = 0;
int base_flag       = 0;
uint32_t timer_data = 0;
static void IRAM_ATTR Timer0_CallBack(void);

// Data display via Serial
void UWB_display() {
    if (Serial2.available()) {
        Serial.println("OK!! ");
    }
    switch (UWB_MODE) {
        case 0:  // Tag mode
            if (UWB_T_NUMBER > 0 && UWB_T_NUMBER < 5) {
                int c = UWB_T_NUMBER;
                int b = 4 - UWB_T_NUMBER;
                while (c > 0) {
                    c--;
                    Serial.print("Tag serial number: ");
                    Serial.println(DATA.substring(2 + c * 11, 3 + c * 11));  // Tag serial number
                    Serial.print("Distance: ");
                    Serial.println(DATA.substring(4 + c * 11, 8 + c * 11));  // Distance
                }
                while (b > 0) {
                    b--;
                    Serial.println("Clearing remaining data slots...");
                }
            }
            break;
        case 1:  // Base station mode
            if (UWB_B_NUMBER == 1) {
                Serial.println("Base station data: ");
                Serial.println(DATA);  // Display data in Base station mode
            }
            break;
    }
}

// UI display via Serial
void UWB_ui_display() {
    Serial.println("UWB Example");
    Serial.println("Tag: press BtnA");
    Serial.println("Base: press BtnB");
    Serial.println("Reset: press BtnC");

    switch (UWB_MODE) {
        case 0:  // Tag mode UI display
            if (UWB_T_NUMBER > 0 && UWB_T_NUMBER < 5) {
                int c = UWB_T_NUMBER;
                int b = 4 - UWB_T_NUMBER;
                while (c > 0) {
                    c--;
                    Serial.print("Tag ");
                    Serial.print(c + 1);  // Tag number
                    Serial.print(" - Distance: ");
                    Serial.println("M");  // Example distance
                }
                while (b > 0) {
                    b--;
                    Serial.println("Clearing additional data slots...");
                }
            }
            break;
        case 1:  // Base station mode UI display
            Serial.print("Base station ID: ");
            Serial.println(UWB_B_NUMBER);
            if (UWB_B_NUMBER == 0) {
                Serial.println("Loading...");
            } else {
                Serial.println("Data loaded successfully.");
            }
            break;
    }
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

// Read UART data
void UWB_readString() {
    switch (UWB_MODE) {
        case 0:  // Tag mode
            if (Serial2.available()) {
                delay(20);
                UWB_T_NUMBER = (Serial2.available() / 11);  // Count the number of Base stations
                delay(20);
                if (UWB_T_NUMBER != UWB_T_UI_NUMBER_1 || UWB_T_UI_NUMBER_2 == 0) {  
                    UWB_T_UI_NUMBER_1 = UWB_T_NUMBER;
                    UWB_T_UI_NUMBER_2 = 1;

                    // Display tag mode info on Serial
                    Serial.print("Tag Mode: Number of base stations: ");
                    Serial.println(UWB_T_NUMBER);
                }
                DATA = Serial2.readString();
                delay(2);
                timer_flag = 0;
                timer_data = 1;
                break;
            } else {
                timer_flag = 1;
            }
            if (timer_data == 0 || timer_data > 8) {  // Check connection with base station
                DATA       = "  0 2F   ";
                timer_flag = 0;

                // No base station connected, send message to serial
                Serial.println("No base station connected.");
            }
            break;
        case 1:  // Base station mode
            if (timer_data == 0 || timer_data > 70) {  // Indicates successful or lost connection with Tag
                if (Serial2.available()) {
                    delay(2);
                    DATA       = Serial2.readString();
                    DATA       = "set up successfully!";
                    timer_data = 1;
                    timer_flag = 1;
                    Serial.println(DATA);  // Output connection success to serial
                    break;
                } else if (timer_data > 0 && Serial2.available() == 0) {
                    DATA       = "Can't find the tag!!!";
                    timer_flag = 0;
                    Serial.println(DATA);  // Output error message to serial
                    break;
                }
            }
            break;
    }
}

// AT command setup
void UWB_setupmode() {
    switch (UWB_MODE) {
        case 0:
            for (int b = 0; b < 2; b++) {  // Repeat twice to stabilize the connection
                delay(50);
                Serial2.write("AT+anchor_tag=0\r\n");  // Set up the Tag
                delay(50);
                Serial2.write("AT+interval=5\r\n");  // Set the calculation precision
                delay(50);
                Serial2.write("AT+switchdis=1\r\n");  // Start measuring distance
                delay(50);
                if (b == 0) {
                    Serial2.write("AT+RST\r\n");  // RESET
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

// Handle button presses
void UWB_Keyscan() {
    if (M5.BtnA.isPressed()) {
        UWB_MODE = 0;
        UWB_setupmode();
        UWB_clear();
        UWB_T_UI_NUMBER_2 = 0;
        Serial.println("Switched to Tag mode.");
    }
    if (M5.BtnB.isPressed()) {
        UWB_MODE = 1;
        if (UWB_B_NUMBER == 4) {
            UWB_B_NUMBER = 0;
        }
        UWB_setupmode();
        UWB_clear();
        UWB_B_NUMBER++;
        Serial.println("Switched to Base station mode.");
    }
    if (M5.BtnC.isPressed()) {
        Serial2.write("AT+RST\r\n");
        UWB_setupmode();
        UWB_clear();
        Serial.println("System reset.");
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
    Serial.begin(115200);
    Serial2.begin(115200, SERIAL_8N1, 32, 26);  // Use RX 26, TX 32 for Serial2
    delay(100);
    UWB_Timer();
    UWB_ui_display();

    xTaskCreate(wifiTask, "WiFiTask", 4096, NULL, 1, NULL);
    xTaskCreate(mqttTask, "MQTTTask", 4096, NULL, 1, NULL);
    xTaskCreate(publishCoordinate, "publishCoordinate", 4096, NULL, 1, NULL);
}

void loop() {
    M5.update();
    // UWB_Keyscan();
    // UWB_readString();
    UWB_display();
    Serial2.println(UWB_MODE);  // Print UWB mode to Serial2 for debugging
}
