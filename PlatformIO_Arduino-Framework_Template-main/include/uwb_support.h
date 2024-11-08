#include "global.h"

extern String DATA;
extern int UWB_MODE;
extern int UWB_T_NUMBER;
extern int UWB_B_NUMBER;
extern int TIME_SLOT;
extern float distancesList[3];
extern int distanceNumber;
extern float basePos[3][2];


void uwbTask(void *pvParameters);  