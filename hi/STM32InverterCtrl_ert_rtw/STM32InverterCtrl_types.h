/*
 * STM32InverterCtrl_types.h
 *
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * Code generation for model "STM32InverterCtrl".
 *
 * Model version              : 1.1
 * Simulink Coder version : 24.2 (R2024b) 21-Jun-2024
 * C source code generated on : Tue Jun 16 21:28:31 2026
 *
 * Target selection: ert.tlc
 * Note: GRT includes extra infrastructure and instrumentation for prototyping
 * Embedded hardware selection: ARM Compatible->ARM Cortex-M
 * Code generation objectives: Unspecified
 * Validation result: Not run
 */

#ifndef STM32InverterCtrl_types_h_
#define STM32InverterCtrl_types_h_
#include "rtwtypes.h"
#include "MW_SVD.h"

/* Custom Type definition for MATLABSystem: '<Root>/DW_L3' */
#include "MW_SVD.h"
#ifndef struct_tag_It6FfJeyDoFmJbBckjpZS
#define struct_tag_It6FfJeyDoFmJbBckjpZS

struct tag_It6FfJeyDoFmJbBckjpZS
{
  boolean_T matlabCodegenIsDeleted;
  int32_T isInitialized;
  boolean_T isSetupComplete;
  MW_Handle_Type MW_DIGITALIO_HANDLE;
};

#endif                                 /* struct_tag_It6FfJeyDoFmJbBckjpZS */

#ifndef typedef_mbed_DigitalWrite_STM32Invert_T
#define typedef_mbed_DigitalWrite_STM32Invert_T

typedef struct tag_It6FfJeyDoFmJbBckjpZS mbed_DigitalWrite_STM32Invert_T;

#endif                             /* typedef_mbed_DigitalWrite_STM32Invert_T */

/* Forward declaration for rtModel */
typedef struct tag_RTM_STM32InverterCtrl_T RT_MODEL_STM32InverterCtrl_T;

#endif                                 /* STM32InverterCtrl_types_h_ */
