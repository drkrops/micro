@echo off
REM ****************************************************************************
REM Vivado (TM) v2019.1 (64-bit)
REM
REM Filename    : simulate.bat
REM Simulator   : Xilinx Vivado Simulator
REM Description : Script for simulating the design by launching the simulator
REM
REM Generated by Vivado on Tue Sep 19 09:52:10 +0300 2023
REM SW Build 2552052 on Fri May 24 14:49:42 MDT 2019
REM
REM Copyright 1986-2019 Xilinx, Inc. All Rights Reserved.
REM
REM usage: simulate.bat
REM
REM ****************************************************************************
echo "xsim tb_rf_riscv_behav -key {Behavioral:sim_1:Functional:tb_rf_riscv} -tclbatch tb_rf_riscv.tcl -view C:/Users/pwnies/laba_3_3/tb_rf_riscv_behav.wcfg -log simulate.log"
call xsim  tb_rf_riscv_behav -key {Behavioral:sim_1:Functional:tb_rf_riscv} -tclbatch tb_rf_riscv.tcl -view C:/Users/pwnies/laba_3_3/tb_rf_riscv_behav.wcfg -log simulate.log
if "%errorlevel%"=="0" goto SUCCESS
if "%errorlevel%"=="1" goto END
:END
exit 1
:SUCCESS
exit 0