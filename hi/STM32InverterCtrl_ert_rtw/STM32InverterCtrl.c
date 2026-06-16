/*
 * STM32InverterCtrl.c
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

#include "STM32InverterCtrl.h"
#include <math.h>
#include "rtwtypes.h"
#include <string.h>

/* Block states (default storage) */
DW_STM32InverterCtrl_T STM32InverterCtrl_DW;

/* Real-time model */
static RT_MODEL_STM32InverterCtrl_T STM32InverterCtrl_M_;
RT_MODEL_STM32InverterCtrl_T *const STM32InverterCtrl_M = &STM32InverterCtrl_M_;

/* Model step function */
void STM32InverterCtrl_step(void)
{
  real_T lastSin_tmp;
  boolean_T rtb_Cmp1;
  boolean_T rtb_Cmp2;
  boolean_T rtb_Cmp3;
  boolean_T rtb_Not1;
  boolean_T rtb_Not2;
  boolean_T rtb_Not3;

  /* Sin: '<Root>/Sin1' */
  if (STM32InverterCtrl_DW.systemEnable != 0) {
    lastSin_tmp = (((STM32InverterCtrl_M->Timing.clockTick0+
                     STM32InverterCtrl_M->Timing.clockTickH0* 4294967296.0)) *
                   2.0E-6);
    STM32InverterCtrl_DW.lastSin = sin(314.15926535897933 * lastSin_tmp);
    STM32InverterCtrl_DW.lastCos = cos(314.15926535897933 * lastSin_tmp);
    STM32InverterCtrl_DW.systemEnable = 0;
  }

  /* Bias: '<Root>/Bias1' incorporates:
   *  Gain: '<Root>/Gthr1'
   *  Sin: '<Root>/Sin1'
   */
  lastSin_tmp = ((STM32InverterCtrl_DW.lastSin * 0.99999980260791843 +
                  STM32InverterCtrl_DW.lastCos * -0.00062831848937625718) *
                 0.99999980260791843 + (STM32InverterCtrl_DW.lastCos *
    0.99999980260791843 - STM32InverterCtrl_DW.lastSin * -0.00062831848937625718)
                 * 0.00062831848937625718) * 0.8 * 50.0 + 50.0;

  /* Saturate: '<Root>/Sat1' */
  if (lastSin_tmp > 100.0) {
    lastSin_tmp = 100.0;
  } else if (lastSin_tmp < 0.0) {
    lastSin_tmp = 0.0;
  }

  /* RelationalOperator: '<Root>/Cmp1' incorporates:
   *  DataTypeConversion: '<Root>/c2dbl'
   *  Saturate: '<Root>/Sat1'
   *  UnitDelay: '<S1>/Output'
   */
  rtb_Cmp1 = (STM32InverterCtrl_DW.Output_DSTATE < lastSin_tmp);

  /* MATLABSystem: '<Root>/DW_H1' incorporates:
   *  Delay: '<Root>/HDel1'
   *  Logic: '<Root>/HAnd1'
   */
  MW_digitalIO_write(STM32InverterCtrl_DW.obj_l.MW_DIGITALIO_HANDLE, rtb_Cmp1 &&
                     STM32InverterCtrl_DW.HDel1_DSTATE[0]);

  /* Logic: '<Root>/Not1' */
  rtb_Not1 = !rtb_Cmp1;

  /* MATLABSystem: '<Root>/DW_L1' incorporates:
   *  Delay: '<Root>/LDel1'
   *  Logic: '<Root>/LAnd1'
   */
  MW_digitalIO_write(STM32InverterCtrl_DW.obj_k.MW_DIGITALIO_HANDLE, rtb_Not1 &&
                     STM32InverterCtrl_DW.LDel1_DSTATE[0]);

  /* Sin: '<Root>/Sin2' */
  if (STM32InverterCtrl_DW.systemEnable_o != 0) {
    lastSin_tmp = (((STM32InverterCtrl_M->Timing.clockTick0+
                     STM32InverterCtrl_M->Timing.clockTickH0* 4294967296.0)) *
                   2.0E-6);
    STM32InverterCtrl_DW.lastSin_j = sin(314.15926535897933 * lastSin_tmp);
    STM32InverterCtrl_DW.lastCos_e = cos(314.15926535897933 * lastSin_tmp);
    STM32InverterCtrl_DW.systemEnable_o = 0;
  }

  /* Bias: '<Root>/Bias2' incorporates:
   *  Gain: '<Root>/Gthr2'
   *  Sin: '<Root>/Sin2'
   */
  lastSin_tmp = ((STM32InverterCtrl_DW.lastSin_j * -0.50054404107742645 +
                  STM32InverterCtrl_DW.lastCos_e * -0.86571107359319344) *
                 0.99999980260791843 + (STM32InverterCtrl_DW.lastCos_e *
    -0.50054404107742645 - STM32InverterCtrl_DW.lastSin_j * -0.86571107359319344)
                 * 0.00062831848937625718) * 0.8 * 50.0 + 50.0;

  /* Saturate: '<Root>/Sat2' */
  if (lastSin_tmp > 100.0) {
    lastSin_tmp = 100.0;
  } else if (lastSin_tmp < 0.0) {
    lastSin_tmp = 0.0;
  }

  /* RelationalOperator: '<Root>/Cmp2' incorporates:
   *  DataTypeConversion: '<Root>/c2dbl'
   *  Saturate: '<Root>/Sat2'
   *  UnitDelay: '<S1>/Output'
   */
  rtb_Cmp2 = (STM32InverterCtrl_DW.Output_DSTATE < lastSin_tmp);

  /* MATLABSystem: '<Root>/DW_H2' incorporates:
   *  Delay: '<Root>/HDel2'
   *  Logic: '<Root>/HAnd2'
   */
  MW_digitalIO_write(STM32InverterCtrl_DW.obj_m.MW_DIGITALIO_HANDLE, rtb_Cmp2 &&
                     STM32InverterCtrl_DW.HDel2_DSTATE[0]);

  /* Logic: '<Root>/Not2' */
  rtb_Not2 = !rtb_Cmp2;

  /* MATLABSystem: '<Root>/DW_L2' incorporates:
   *  Delay: '<Root>/LDel2'
   *  Logic: '<Root>/LAnd2'
   */
  MW_digitalIO_write(STM32InverterCtrl_DW.obj_c.MW_DIGITALIO_HANDLE, rtb_Not2 &&
                     STM32InverterCtrl_DW.LDel2_DSTATE[0]);

  /* Sin: '<Root>/Sin3' */
  if (STM32InverterCtrl_DW.systemEnable_g != 0) {
    lastSin_tmp = (((STM32InverterCtrl_M->Timing.clockTick0+
                     STM32InverterCtrl_M->Timing.clockTickH0* 4294967296.0)) *
                   2.0E-6);
    STM32InverterCtrl_DW.lastSin_n = sin(314.15926535897933 * lastSin_tmp);
    STM32InverterCtrl_DW.lastCos_h = cos(314.15926535897933 * lastSin_tmp);
    STM32InverterCtrl_DW.systemEnable_g = 0;
  }

  /* Bias: '<Root>/Bias3' incorporates:
   *  Gain: '<Root>/Gthr3'
   *  Sin: '<Root>/Sin3'
   */
  lastSin_tmp = ((STM32InverterCtrl_DW.lastSin_n * -0.4994557615304922 +
                  STM32InverterCtrl_DW.lastCos_h * 0.86633939208256949) *
                 0.99999980260791843 + (STM32InverterCtrl_DW.lastCos_h *
    -0.4994557615304922 - STM32InverterCtrl_DW.lastSin_n * 0.86633939208256949) *
                 0.00062831848937625718) * 0.8 * 50.0 + 50.0;

  /* Saturate: '<Root>/Sat3' */
  if (lastSin_tmp > 100.0) {
    lastSin_tmp = 100.0;
  } else if (lastSin_tmp < 0.0) {
    lastSin_tmp = 0.0;
  }

  /* RelationalOperator: '<Root>/Cmp3' incorporates:
   *  DataTypeConversion: '<Root>/c2dbl'
   *  Saturate: '<Root>/Sat3'
   *  UnitDelay: '<S1>/Output'
   */
  rtb_Cmp3 = (STM32InverterCtrl_DW.Output_DSTATE < lastSin_tmp);

  /* MATLABSystem: '<Root>/DW_H3' incorporates:
   *  Delay: '<Root>/HDel3'
   *  Logic: '<Root>/HAnd3'
   */
  MW_digitalIO_write(STM32InverterCtrl_DW.obj_d.MW_DIGITALIO_HANDLE, rtb_Cmp3 &&
                     STM32InverterCtrl_DW.HDel3_DSTATE[0]);

  /* Logic: '<Root>/Not3' */
  rtb_Not3 = !rtb_Cmp3;

  /* MATLABSystem: '<Root>/DW_L3' incorporates:
   *  Delay: '<Root>/LDel3'
   *  Logic: '<Root>/LAnd3'
   */
  MW_digitalIO_write(STM32InverterCtrl_DW.obj.MW_DIGITALIO_HANDLE, rtb_Not3 &&
                     STM32InverterCtrl_DW.LDel3_DSTATE[0]);

  /* Switch: '<S3>/FixPt Switch' incorporates:
   *  Constant: '<S2>/FixPt Constant'
   *  Sum: '<S2>/FixPt Sum1'
   *  UnitDelay: '<S1>/Output'
   */
  if ((uint8_T)(STM32InverterCtrl_DW.Output_DSTATE + 1) > 99) {
    /* Update for UnitDelay: '<S1>/Output' incorporates:
     *  Constant: '<S3>/Constant'
     */
    STM32InverterCtrl_DW.Output_DSTATE = 0U;
  } else {
    /* Update for UnitDelay: '<S1>/Output' */
    STM32InverterCtrl_DW.Output_DSTATE++;
  }

  /* End of Switch: '<S3>/FixPt Switch' */

  /* Update for Sin: '<Root>/Sin1' */
  lastSin_tmp = STM32InverterCtrl_DW.lastSin;
  STM32InverterCtrl_DW.lastSin = STM32InverterCtrl_DW.lastSin *
    0.99999980260791843 + STM32InverterCtrl_DW.lastCos * 0.00062831848937625718;
  STM32InverterCtrl_DW.lastCos = STM32InverterCtrl_DW.lastCos *
    0.99999980260791843 - lastSin_tmp * 0.00062831848937625718;

  /* Update for Delay: '<Root>/HDel1' */
  STM32InverterCtrl_DW.HDel1_DSTATE[0] = STM32InverterCtrl_DW.HDel1_DSTATE[1];
  STM32InverterCtrl_DW.HDel1_DSTATE[1] = rtb_Cmp1;

  /* Update for Delay: '<Root>/LDel1' */
  STM32InverterCtrl_DW.LDel1_DSTATE[0] = STM32InverterCtrl_DW.LDel1_DSTATE[1];
  STM32InverterCtrl_DW.LDel1_DSTATE[1] = rtb_Not1;

  /* Update for Sin: '<Root>/Sin2' */
  lastSin_tmp = STM32InverterCtrl_DW.lastSin_j;
  STM32InverterCtrl_DW.lastSin_j = STM32InverterCtrl_DW.lastSin_j *
    0.99999980260791843 + STM32InverterCtrl_DW.lastCos_e *
    0.00062831848937625718;
  STM32InverterCtrl_DW.lastCos_e = STM32InverterCtrl_DW.lastCos_e *
    0.99999980260791843 - lastSin_tmp * 0.00062831848937625718;

  /* Update for Delay: '<Root>/HDel2' */
  STM32InverterCtrl_DW.HDel2_DSTATE[0] = STM32InverterCtrl_DW.HDel2_DSTATE[1];
  STM32InverterCtrl_DW.HDel2_DSTATE[1] = rtb_Cmp2;

  /* Update for Delay: '<Root>/LDel2' */
  STM32InverterCtrl_DW.LDel2_DSTATE[0] = STM32InverterCtrl_DW.LDel2_DSTATE[1];
  STM32InverterCtrl_DW.LDel2_DSTATE[1] = rtb_Not2;

  /* Update for Sin: '<Root>/Sin3' */
  lastSin_tmp = STM32InverterCtrl_DW.lastSin_n;
  STM32InverterCtrl_DW.lastSin_n = STM32InverterCtrl_DW.lastSin_n *
    0.99999980260791843 + STM32InverterCtrl_DW.lastCos_h *
    0.00062831848937625718;
  STM32InverterCtrl_DW.lastCos_h = STM32InverterCtrl_DW.lastCos_h *
    0.99999980260791843 - lastSin_tmp * 0.00062831848937625718;

  /* Update for Delay: '<Root>/HDel3' */
  STM32InverterCtrl_DW.HDel3_DSTATE[0] = STM32InverterCtrl_DW.HDel3_DSTATE[1];
  STM32InverterCtrl_DW.HDel3_DSTATE[1] = rtb_Cmp3;

  /* Update for Delay: '<Root>/LDel3' */
  STM32InverterCtrl_DW.LDel3_DSTATE[0] = STM32InverterCtrl_DW.LDel3_DSTATE[1];
  STM32InverterCtrl_DW.LDel3_DSTATE[1] = rtb_Not3;

  /* Update absolute time for base rate */
  /* The "clockTick0" counts the number of times the code of this task has
   * been executed. The resolution of this integer timer is 2.0E-6, which is the step size
   * of the task. Size of "clockTick0" ensures timer will not overflow during the
   * application lifespan selected.
   * Timer of this task consists of two 32 bit unsigned integers.
   * The two integers represent the low bits Timing.clockTick0 and the high bits
   * Timing.clockTickH0. When the low bit overflows to 0, the high bits increment.
   */
  STM32InverterCtrl_M->Timing.clockTick0++;
  if (!STM32InverterCtrl_M->Timing.clockTick0) {
    STM32InverterCtrl_M->Timing.clockTickH0++;
  }
}

/* Model initialize function */
void STM32InverterCtrl_initialize(void)
{
  /* Registration code */

  /* initialize real-time model */
  (void) memset((void *)STM32InverterCtrl_M, 0,
                sizeof(RT_MODEL_STM32InverterCtrl_T));

  /* states (dwork) */
  (void) memset((void *)&STM32InverterCtrl_DW, 0,
                sizeof(DW_STM32InverterCtrl_T));

  /* Start for MATLABSystem: '<Root>/DW_H1' */
  STM32InverterCtrl_DW.obj_l.matlabCodegenIsDeleted = false;
  STM32InverterCtrl_DW.objisempty_d = true;
  STM32InverterCtrl_DW.obj_l.isInitialized = 1;
  STM32InverterCtrl_DW.obj_l.MW_DIGITALIO_HANDLE = MW_digitalIO_open(PA_6, 1);
  STM32InverterCtrl_DW.obj_l.isSetupComplete = true;

  /* Start for MATLABSystem: '<Root>/DW_L1' */
  STM32InverterCtrl_DW.obj_k.matlabCodegenIsDeleted = false;
  STM32InverterCtrl_DW.objisempty_n = true;
  STM32InverterCtrl_DW.obj_k.isInitialized = 1;
  STM32InverterCtrl_DW.obj_k.MW_DIGITALIO_HANDLE = MW_digitalIO_open(PA_5, 1);
  STM32InverterCtrl_DW.obj_k.isSetupComplete = true;

  /* Start for MATLABSystem: '<Root>/DW_H2' */
  STM32InverterCtrl_DW.obj_m.matlabCodegenIsDeleted = false;
  STM32InverterCtrl_DW.objisempty_cj = true;
  STM32InverterCtrl_DW.obj_m.isInitialized = 1;
  STM32InverterCtrl_DW.obj_m.MW_DIGITALIO_HANDLE = MW_digitalIO_open(PB_3, 1);
  STM32InverterCtrl_DW.obj_m.isSetupComplete = true;

  /* Start for MATLABSystem: '<Root>/DW_L2' */
  STM32InverterCtrl_DW.obj_c.matlabCodegenIsDeleted = false;
  STM32InverterCtrl_DW.objisempty_c = true;
  STM32InverterCtrl_DW.obj_c.isInitialized = 1;
  STM32InverterCtrl_DW.obj_c.MW_DIGITALIO_HANDLE = MW_digitalIO_open(PB_5, 1);
  STM32InverterCtrl_DW.obj_c.isSetupComplete = true;

  /* Start for MATLABSystem: '<Root>/DW_H3' */
  STM32InverterCtrl_DW.obj_d.matlabCodegenIsDeleted = false;
  STM32InverterCtrl_DW.objisempty_f = true;
  STM32InverterCtrl_DW.obj_d.isInitialized = 1;
  STM32InverterCtrl_DW.obj_d.MW_DIGITALIO_HANDLE = MW_digitalIO_open(PB_4, 1);
  STM32InverterCtrl_DW.obj_d.isSetupComplete = true;

  /* Start for MATLABSystem: '<Root>/DW_L3' */
  STM32InverterCtrl_DW.obj.matlabCodegenIsDeleted = false;
  STM32InverterCtrl_DW.objisempty = true;
  STM32InverterCtrl_DW.obj.isInitialized = 1;
  STM32InverterCtrl_DW.obj.MW_DIGITALIO_HANDLE = MW_digitalIO_open(PA_4, 1);
  STM32InverterCtrl_DW.obj.isSetupComplete = true;

  /* InitializeConditions for UnitDelay: '<S1>/Output' */
  STM32InverterCtrl_DW.Output_DSTATE = 0U;

  /* InitializeConditions for Delay: '<Root>/HDel1' */
  STM32InverterCtrl_DW.HDel1_DSTATE[0] = false;

  /* InitializeConditions for Delay: '<Root>/LDel1' */
  STM32InverterCtrl_DW.LDel1_DSTATE[0] = false;

  /* InitializeConditions for Delay: '<Root>/HDel2' */
  STM32InverterCtrl_DW.HDel2_DSTATE[0] = false;

  /* InitializeConditions for Delay: '<Root>/LDel2' */
  STM32InverterCtrl_DW.LDel2_DSTATE[0] = false;

  /* InitializeConditions for Delay: '<Root>/HDel3' */
  STM32InverterCtrl_DW.HDel3_DSTATE[0] = false;

  /* InitializeConditions for Delay: '<Root>/LDel3' */
  STM32InverterCtrl_DW.LDel3_DSTATE[0] = false;

  /* InitializeConditions for Delay: '<Root>/HDel1' */
  STM32InverterCtrl_DW.HDel1_DSTATE[1] = false;

  /* InitializeConditions for Delay: '<Root>/LDel1' */
  STM32InverterCtrl_DW.LDel1_DSTATE[1] = false;

  /* InitializeConditions for Delay: '<Root>/HDel2' */
  STM32InverterCtrl_DW.HDel2_DSTATE[1] = false;

  /* InitializeConditions for Delay: '<Root>/LDel2' */
  STM32InverterCtrl_DW.LDel2_DSTATE[1] = false;

  /* InitializeConditions for Delay: '<Root>/HDel3' */
  STM32InverterCtrl_DW.HDel3_DSTATE[1] = false;

  /* InitializeConditions for Delay: '<Root>/LDel3' */
  STM32InverterCtrl_DW.LDel3_DSTATE[1] = false;

  /* Enable for Sin: '<Root>/Sin1' */
  STM32InverterCtrl_DW.systemEnable = 1;

  /* Enable for Sin: '<Root>/Sin2' */
  STM32InverterCtrl_DW.systemEnable_o = 1;

  /* Enable for Sin: '<Root>/Sin3' */
  STM32InverterCtrl_DW.systemEnable_g = 1;
}

/* Model terminate function */
void STM32InverterCtrl_terminate(void)
{
  /* Terminate for MATLABSystem: '<Root>/DW_H1' */
  if (!STM32InverterCtrl_DW.obj_l.matlabCodegenIsDeleted) {
    STM32InverterCtrl_DW.obj_l.matlabCodegenIsDeleted = true;
    if ((STM32InverterCtrl_DW.obj_l.isInitialized == 1) &&
        STM32InverterCtrl_DW.obj_l.isSetupComplete) {
      MW_digitalIO_close(STM32InverterCtrl_DW.obj_l.MW_DIGITALIO_HANDLE);
    }
  }

  /* End of Terminate for MATLABSystem: '<Root>/DW_H1' */

  /* Terminate for MATLABSystem: '<Root>/DW_L1' */
  if (!STM32InverterCtrl_DW.obj_k.matlabCodegenIsDeleted) {
    STM32InverterCtrl_DW.obj_k.matlabCodegenIsDeleted = true;
    if ((STM32InverterCtrl_DW.obj_k.isInitialized == 1) &&
        STM32InverterCtrl_DW.obj_k.isSetupComplete) {
      MW_digitalIO_close(STM32InverterCtrl_DW.obj_k.MW_DIGITALIO_HANDLE);
    }
  }

  /* End of Terminate for MATLABSystem: '<Root>/DW_L1' */

  /* Terminate for MATLABSystem: '<Root>/DW_H2' */
  if (!STM32InverterCtrl_DW.obj_m.matlabCodegenIsDeleted) {
    STM32InverterCtrl_DW.obj_m.matlabCodegenIsDeleted = true;
    if ((STM32InverterCtrl_DW.obj_m.isInitialized == 1) &&
        STM32InverterCtrl_DW.obj_m.isSetupComplete) {
      MW_digitalIO_close(STM32InverterCtrl_DW.obj_m.MW_DIGITALIO_HANDLE);
    }
  }

  /* End of Terminate for MATLABSystem: '<Root>/DW_H2' */

  /* Terminate for MATLABSystem: '<Root>/DW_L2' */
  if (!STM32InverterCtrl_DW.obj_c.matlabCodegenIsDeleted) {
    STM32InverterCtrl_DW.obj_c.matlabCodegenIsDeleted = true;
    if ((STM32InverterCtrl_DW.obj_c.isInitialized == 1) &&
        STM32InverterCtrl_DW.obj_c.isSetupComplete) {
      MW_digitalIO_close(STM32InverterCtrl_DW.obj_c.MW_DIGITALIO_HANDLE);
    }
  }

  /* End of Terminate for MATLABSystem: '<Root>/DW_L2' */

  /* Terminate for MATLABSystem: '<Root>/DW_H3' */
  if (!STM32InverterCtrl_DW.obj_d.matlabCodegenIsDeleted) {
    STM32InverterCtrl_DW.obj_d.matlabCodegenIsDeleted = true;
    if ((STM32InverterCtrl_DW.obj_d.isInitialized == 1) &&
        STM32InverterCtrl_DW.obj_d.isSetupComplete) {
      MW_digitalIO_close(STM32InverterCtrl_DW.obj_d.MW_DIGITALIO_HANDLE);
    }
  }

  /* End of Terminate for MATLABSystem: '<Root>/DW_H3' */

  /* Terminate for MATLABSystem: '<Root>/DW_L3' */
  if (!STM32InverterCtrl_DW.obj.matlabCodegenIsDeleted) {
    STM32InverterCtrl_DW.obj.matlabCodegenIsDeleted = true;
    if ((STM32InverterCtrl_DW.obj.isInitialized == 1) &&
        STM32InverterCtrl_DW.obj.isSetupComplete) {
      MW_digitalIO_close(STM32InverterCtrl_DW.obj.MW_DIGITALIO_HANDLE);
    }
  }

  /* End of Terminate for MATLABSystem: '<Root>/DW_L3' */
}
