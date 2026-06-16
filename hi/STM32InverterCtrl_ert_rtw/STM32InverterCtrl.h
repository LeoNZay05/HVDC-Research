/*
 * STM32InverterCtrl.h
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

#ifndef STM32InverterCtrl_h_
#define STM32InverterCtrl_h_
#ifndef STM32InverterCtrl_COMMON_INCLUDES_
#define STM32InverterCtrl_COMMON_INCLUDES_
#include "rtwtypes.h"
#include "rtw_continuous.h"
#include "rtw_solver.h"
#include "math.h"
#include "MW_MbedPinInterface.h"
#include "MW_digitalIO.h"
#endif                                 /* STM32InverterCtrl_COMMON_INCLUDES_ */

#include "STM32InverterCtrl_types.h"
#include <string.h>
#include <stddef.h>
#include "MW_target_hardware_resources.h"

/* Macros for accessing real-time model data structure */
#ifndef rtmGetErrorStatus
#define rtmGetErrorStatus(rtm)         ((rtm)->errorStatus)
#endif

#ifndef rtmSetErrorStatus
#define rtmSetErrorStatus(rtm, val)    ((rtm)->errorStatus = (val))
#endif

/* Block states (default storage) for system '<Root>' */
typedef struct {
  mbed_DigitalWrite_STM32Invert_T obj; /* '<Root>/DW_L3' */
  mbed_DigitalWrite_STM32Invert_T obj_c;/* '<Root>/DW_L2' */
  mbed_DigitalWrite_STM32Invert_T obj_k;/* '<Root>/DW_L1' */
  mbed_DigitalWrite_STM32Invert_T obj_d;/* '<Root>/DW_H3' */
  mbed_DigitalWrite_STM32Invert_T obj_m;/* '<Root>/DW_H2' */
  mbed_DigitalWrite_STM32Invert_T obj_l;/* '<Root>/DW_H1' */
  real_T lastSin;                      /* '<Root>/Sin1' */
  real_T lastCos;                      /* '<Root>/Sin1' */
  real_T lastSin_j;                    /* '<Root>/Sin2' */
  real_T lastCos_e;                    /* '<Root>/Sin2' */
  real_T lastSin_n;                    /* '<Root>/Sin3' */
  real_T lastCos_h;                    /* '<Root>/Sin3' */
  int32_T systemEnable;                /* '<Root>/Sin1' */
  int32_T systemEnable_o;              /* '<Root>/Sin2' */
  int32_T systemEnable_g;              /* '<Root>/Sin3' */
  uint8_T Output_DSTATE;               /* '<S1>/Output' */
  boolean_T HDel1_DSTATE[2];           /* '<Root>/HDel1' */
  boolean_T LDel1_DSTATE[2];           /* '<Root>/LDel1' */
  boolean_T HDel2_DSTATE[2];           /* '<Root>/HDel2' */
  boolean_T LDel2_DSTATE[2];           /* '<Root>/LDel2' */
  boolean_T HDel3_DSTATE[2];           /* '<Root>/HDel3' */
  boolean_T LDel3_DSTATE[2];           /* '<Root>/LDel3' */
  boolean_T objisempty;                /* '<Root>/DW_L3' */
  boolean_T objisempty_c;              /* '<Root>/DW_L2' */
  boolean_T objisempty_n;              /* '<Root>/DW_L1' */
  boolean_T objisempty_f;              /* '<Root>/DW_H3' */
  boolean_T objisempty_cj;             /* '<Root>/DW_H2' */
  boolean_T objisempty_d;              /* '<Root>/DW_H1' */
} DW_STM32InverterCtrl_T;

/* Real-time Model Data Structure */
struct tag_RTM_STM32InverterCtrl_T {
  const char_T *errorStatus;

  /*
   * Timing:
   * The following substructure contains information regarding
   * the timing information for the model.
   */
  struct {
    uint32_T clockTick0;
    uint32_T clockTickH0;
  } Timing;
};

/* Block states (default storage) */
extern DW_STM32InverterCtrl_T STM32InverterCtrl_DW;

/* Model entry point functions */
extern void STM32InverterCtrl_initialize(void);
extern void STM32InverterCtrl_step(void);
extern void STM32InverterCtrl_terminate(void);

/* Real-time Model object */
extern RT_MODEL_STM32InverterCtrl_T *const STM32InverterCtrl_M;
extern volatile boolean_T stopRequested;
extern volatile boolean_T runModel;

/*-
 * These blocks were eliminated from the model due to optimizations:
 *
 * Block '<S1>/Data Type Propagation' : Unused code path elimination
 * Block '<S2>/FixPt Data Type Duplicate' : Unused code path elimination
 * Block '<S3>/FixPt Data Type Duplicate1' : Unused code path elimination
 */

/*-
 * The generated code includes comments that allow you to trace directly
 * back to the appropriate location in the model.  The basic format
 * is <system>/block_name, where system is the system number (uniquely
 * assigned by Simulink) and block_name is the name of the block.
 *
 * Use the MATLAB hilite_system command to trace the generated code back
 * to the model.  For example,
 *
 * hilite_system('<S3>')    - opens system 3
 * hilite_system('<S3>/Kp') - opens and selects block Kp which resides in S3
 *
 * Here is the system hierarchy for this model
 *
 * '<Root>' : 'STM32InverterCtrl'
 * '<S1>'   : 'STM32InverterCtrl/Carrier'
 * '<S2>'   : 'STM32InverterCtrl/Carrier/Increment Real World'
 * '<S3>'   : 'STM32InverterCtrl/Carrier/Wrap To Zero'
 */
#endif                                 /* STM32InverterCtrl_h_ */
