#include "global.h"

String DATA = " ";

int UWB_MODE = 0;
int UWB_T_NUMBER = 0; // number of anchors
int UWB_B_NUMBER = 0; // id of this anchor

hw_timer_t *timer   = NULL;
int timer_flag      = 0;
uint32_t timer_data = 0;

void UWB_readString() {
    switch (UWB_MODE) {
        case 0:
            if (Serial2.available()) {
                delay(20);
                UWB_T_NUMBER =
                    (Serial2.available() /
                     11);  // Count the number of Base stations  计算基站数目
                delay(20);
                Serial.println(UWB_T_NUMBER);
                DATA = Serial2.readString();
                delay(2);
                timer_flag = 0;
                timer_data = 1;
                break;
            } else {
                timer_flag = 1;
            }
            if (timer_data == 0 ||
                timer_data > 8) {  // Count the number of Base stations
                                   // 提示与基站0断连（测试）
                DATA       = "  0 2F   ";
                timer_flag = 0;
            }
            break;
        case 1:
            if (timer_data == 0 ||
                timer_data > 70) {  // Indicates successful or lost connection
                                    // with Tag  提示与标签连接成功或丢失断连
                if (Serial2.available()) {
                    delay(2);
                    DATA       = Serial2.readString();
                    DATA       = "set up successfully!";
                    timer_data = 1;
                    timer_flag = 1;
                    break;
                } else if (timer_data > 0 && Serial2.available() == 0) {
                    DATA       = "Can't find the tag!!!";
                    timer_flag = 0;
                    break;
                }
            }
            break;
    }
}


void UWB_clear() {
    if (Serial2.available()) {
        delay(3);
        DATA = Serial2.readString();
    }
    DATA       = "";
    timer_flag = 0;
    timer_data = 0;
}

void UWB_setupmode() {
    switch (UWB_MODE) {
        case 0:
            for (int b = 0; b < 2;
                 b++) {  // Repeat twice to stabilize the connection
                delay(50);
                Serial2.write("AT+anchor_tag=0\r\n");  // Set up the Tag
                                                       // 设置标签
                delay(50);
                Serial2.write(
                    "AT+interval=5\r\n");  // Set the calculation precision, the
                                           // larger the response is, the slower
                                           // it will be
                delay(50);  //设置计算精度，越大响应越慢
                Serial2.write(
                    "AT+switchdis=1\r\n");  // Began to distance 开始测距
                delay(50);
                if (b == 0) {
                    Serial2.write("AT+RST\r\n");  // RESET 复位
                }
            }
            UWB_clear();
            break;
        case 1:
            for (int b = 0; b < 2; b++) {
                delay(50);
                Serial2.write(
                    "AT+anchor_tag=1,");  // Set the base station 设置基站
                Serial2.print(
                    UWB_B_NUMBER);  // UWB_B_NUMBER is base station ID0~ID3
                Serial2.write("\r\n");
                delay(1);
                delay(50);
                if (b == 0) {
                    Serial2.write("AT+RST\r\n");
                }
            }
            UWB_clear();
            break;
    }
}


void UWB_Keyscan() {
    if (UWB_MODE == 0) {
        UWB_setupmode();
        UWB_clear();
    }
    if (UWB_MODE == 1) {
        if (UWB_B_NUMBER == 4) {
            UWB_B_NUMBER = 0;
        }
        UWB_setupmode();
        UWB_clear();
        UWB_B_NUMBER++;
    }
}

static void IRAM_ATTR Timer0_CallBack(void)  // Timer function 定时器函数
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

void UWB_Timer() {
    timer = timerBegin(0, 80, true);  // Timer setting 定时器设置
    timerAttachInterrupt(timer, Timer0_CallBack, true);
    timerAlarmWrite(timer, 1000000, true);
    timerAlarmEnable(timer);
}

void setup(){
  Serial.begin(115200);

  // xTaskCreate(wifiTask, "WiFiTask", 4096, NULL, 1, NULL);
  // xTaskCreate(mqttTask, "MQTTTask", 4096, NULL, 1, NULL);
  Serial2.begin(115200, SERIAL_8N1, 32, 26);
  if (Serial2.available()) {
    Serial.println("Serial2 is available");
  }
  UWB_Timer();
  delay(1000);
}

void loop(){
  // Nothing to do here, FreeRTOS tasks handle the work
  UWB_Keyscan();
  UWB_readString();
  if (Serial.available()) {
    Serial.println("Serial is available");
  } else {
    Serial.println("Serial is not available");
  }
  Serial.println("data is: " + DATA);
  delay(2000);
}