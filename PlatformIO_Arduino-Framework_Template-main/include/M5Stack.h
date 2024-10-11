#ifndef _M5STACK_H_
#define _M5STACK_H_

#include <Arduino.h>
#include <SPI.h>
#include <Wire.h>

#include "FS.h"
#include "SD.h"
#include "Power.h"

class M5Stack {
   public:
    M5Stack();
    void begin();
    void update();

    POWER Power;

// Button API
};

extern M5Stack M5;
#define m5      M5
#define lcd     Lcd
#define imu     Imu
#define IMU     Imu
#define MPU6886 Mpu6886
#define mpu6886 Mpu6886
#define SH200Q  Sh200Q
#define sh200q  Sh200Q
#else
#error "This library only supports boards with ESP32 processor."
#endif
