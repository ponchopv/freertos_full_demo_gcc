# freertos_demo_gcc
FreeRTOS Demo for MSP432 with GCC

This is the port of the FreeRTOS for the ARM MSP432 TI microntroller.

It is compiled through a makefile so compiling is independant of any IDE but the CCS project is included for debugging purposes.

The project compiles the demo project from the FreeRTOS official port http://www.freertos.org/TI_MSP432_Free_RTOS_Demo.html which cannot be compiled with an open compiler.

This project was designed to run in the MSP432P401R LaunchPad http://www.ti.com/tool/msp-exp432p401r 

Setup for linux:

1. Download TI CCS and ensure you install the GCC compiler. http://www.ti.com/tool/ccstudio
3. Rename the project to freertos_full_demo_gcc
2. Import the project in CCS.

Setup for windows:

1. Download TI CCS and ensure you install the GCC compiler. http://www.ti.com/tool/ccstudio
2. Rename the project to freertos_full_demo_gcc
3. Import the project in CCS.
4. Download cygwin
5. Update the makefile to point to your compiler path.

Compile the project:

1. Compile it with CCS (ensure build.sh is executable).
2. Alternatively run make all.

Debug:

1. In project Properties->Run/Debug Setting/Edit in tab Program, update the Program field with the path to your workspace. It should be like: YOUR_CCS_WORKSPACE_PATH/free_rtos_demo_gcc/output/free_rtos_demo.out
2. (Alternatively) Use make debug

Testing the Full Demo in Linux (for windows use putty):

1. Install cu.
2. Execute: cu -l /dev/ttyACM0 -s 19200
3. Type help to see the avilable commands.

The following changes were done to make it compile:

1. Folders copied/moved so it doesn't compile directly in the FreeRTOS original folder organization but it would be very easy to integrate the makefile into the original project.

2. FreeRTOSConfig.h - configMINIMAL_STACK_SIZE increased to 150. 

3. FreeRTOSConfig.h - Conditional compile condition for GCC added to avoid the mask of function vPortSVCHandler.

4. In reset interrupt function, resetISR(), the watchdog was disabled to allow the memory copying to be completed.

5. Interrupts were configured in file startup_msp432p401r_gcc.c 

6. In main_full.c, tasks prvRegTestTaskEntry1 and prvRegTestTaskEntry1 were not created since they were implemented in assembly for TI compiler so they need some time to be ported to GCC compiler.

7.  In main_full.c there is an issue with function xAreTimerDemoTasksStillRunning() since it makes the program to fall into  a trap.


