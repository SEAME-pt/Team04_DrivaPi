/**
  ******************************************************************************
  * @file           : i2c_integration_test.h
  * @brief          : Integration test header for I2C motor controllers
  ******************************************************************************
  */

#ifndef __I2C_INTEGRATION_TEST_H
#define __I2C_INTEGRATION_TEST_H

#ifdef __cplusplus
extern "C" {
#endif

#include "pca9685.h"
#include <stdio.h>
#include <stdarg.h>


/**
 * @brief Run complete I2C integration test suite
 * @return 0 if all tests pass, -1 if any test fails
 */
int32_t RunI2CIntegrationTests(void);


#ifdef __cplusplus
}
#endif

#endif /* __I2C_INTEGRATION_TEST_H */
