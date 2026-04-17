#ifndef __MODULES_H
#define __MODULES_H

#ifdef __cplusplus
extern "C" {
#endif

#include "tx_api.h"
#include "txm_module.h"
#include "speed_sensor_module_image.h"
#include "sensors_module_image.h"
#include "ultrasonic_module_image.h"
#include "dc_motor_module_image.h"
#include "servo_motor_module_image.h"
#include "health_module_image.h"
#include "txm_module_port.h"

UINT ModulesInit(void);

#ifdef __cplusplus
}
#endif

#endif /* __MODULES_H */