#===============================================================
#
#    Copyright (C) 2016 Alfonso Pantoja. All rights reserved
#
#    This file is free; you can redistribute it and/or modify it under
#    the terms of the GNU General Public License (version 3) as published by the
#    Free Software Foundation.
#===============================================================
$(info Using Device MSP432P401R as default)


#======================= Environment setup =======================
RM := rm -rf
MKDIR = mkdir -p -- $@
DEVICE=MSP432P401R
OUTPUT_DIR := output
BASE_DIR := /opt/ti/ccsv6/ccs_base
COMPILER_DIR := /opt/ti/ccsv6/tools/compiler/gcc-arm-none-eabi-4_9-2015q3
TI_DRVLIB_DIR := ./driverlib
TI_DRVLIB_LIB_DIR := $(TI_DRVLIB_DIR)/gcc
TI_DRVLIB_LIB := msp432
GCC_MSP_INC_DIR ?= $(BASE_DIR)/arm/include
GCC_CMSIS_INC_DIR ?= $(GCC_MSP_INC_DIR)/CMSIS
LDDIR := $(GCC_MSP_INC_DIR)/$(shell echo $(DEVICE) | tr A-Z a-z)

#======================= Path Setup =======================
OS_DIR := ./FreeRTOS
OS_SOURCE := $(OS_DIR)/Source
OS_PORT := $(OS_SOURCE)/portable/GCC/ARM_CM4F 
OS_INCLUDE := $(OS_SOURCE)/include
OS_DEMO_COMMON_INC_DIR := $(OS_DIR)/Demo/Common/include
DEMO_PATH := ./Demo
PORT_DEMO := $(DEMO_PATH)/SimplyBlinkyDemo
OS_MEM_MGR_DIR := $(OS_SOURCE)/portable/MemMang
OS_MEM_MGR := $(OS_MEM_MGR_DIR)/heap_2.c

#Full Demo source folders
   FULL_DEMO_PATHS = $(DEMO_PATH)/Full_Demo
   FULL_DEMO_PATHS += ./FreeRTOS-Plus/Source/FreeRTOS-Plus-CLI
	
#Specific files used by Full Demo
   FULL_DEMO_PATH_EXTRA = ./FreeRTOS-Plus/Demo/Common/FreeRTOS_Plus_CLI_Demos
   FULL_DEMO_SRC_EXTRA = $(FULL_DEMO_PATH_EXTRA)/UARTCommandConsole.c
   FULL_DEMO_SRC_EXTRA += $(FULL_DEMO_PATH_EXTRA)/Sample-CLI-commands.c

   FULL_DEMO_PATH_MINIMAL = $(OS_DIR)/Demo/Common/Minimal
   FULL_DEMO_SRC_MINIMAL = $(FULL_DEMO_PATH_MINIMAL)/countsem.c
   FULL_DEMO_SRC_MINIMAL += $(FULL_DEMO_PATH_MINIMAL)/EventGroupsDemo.c
   FULL_DEMO_SRC_MINIMAL += $(FULL_DEMO_PATH_MINIMAL)/GenQTest.c
   FULL_DEMO_SRC_MINIMAL += $(FULL_DEMO_PATH_MINIMAL)/IntQueue.c
   FULL_DEMO_SRC_MINIMAL += $(FULL_DEMO_PATH_MINIMAL)/IntSemTest.c
   FULL_DEMO_SRC_MINIMAL += $(FULL_DEMO_PATH_MINIMAL)/recmutex.c
   FULL_DEMO_SRC_MINIMAL += $(FULL_DEMO_PATH_MINIMAL)/semtest.c
   FULL_DEMO_SRC_MINIMAL += $(FULL_DEMO_PATH_MINIMAL)/sp_flop.c
   FULL_DEMO_SRC_MINIMAL += $(FULL_DEMO_PATH_MINIMAL)/TaskNotify.c
   FULL_DEMO_SRC_MINIMAL += $(FULL_DEMO_PATH_MINIMAL)/TimerDemo.c

#Full Demo include folders
   FULL_DEMO_INCLUDES = -I $(OS_DIR)/Demo/Common/include
   FULL_DEMO_INCLUDES += -I $(DEMO_PATH)/Full_Demo
   FULL_DEMO_INCLUDES += -I ./FreeRTOS/Source/portable/GCC/ARM_CM4F
   FULL_DEMO_INCLUDES += -I ./FreeRTOS-Plus/Source/FreeRTOS-Plus-CLI


#======================= Compiler executable =======================
GCC_BIN_DIR ?= $(COMPILER_DIR)/bin
GCC_INC_DIR ?= $(COMPILER_DIR)/arm-none-eabi/include
#=======================
CC := $(GCC_BIN_DIR)/arm-none-eabi-gcc
GDB := $(GCC_BIN_DIR)/arm-none-eabi-gdb
#======================= Compiler parameters =======================
INCLUDES := -I $(GCC_CMSIS_INC_DIR) -I $(GCC_MSP_INC_DIR) -I $(GCC_INC_DIR) \
-I $(OS_INCLUDE) -I $(TI_DRVLIB_DIR) -I $(OS_PORT) -I $(OS_DEMO_COMMON_INC_DIR)\
-I $(DEMO_PATH) $(FULL_DEMO_INCLUDES)
CFLAGS := -mcpu=cortex-m4 -march=armv7e-m -mfloat-abi=hard -mfpu=fpv4-sp-d16\
 -mthumb -D__$(DEVICE)__ -DTARGET_IS_MSP432P4XX -Dgcc $(FREE_RTOS_FULL_DEMO)\
  -g -gstrict-dwarf -Wall -ffunction-sections -fdata-sections -MD -std=c99 
LDFLAGS = -mcpu=cortex-m4 -march=armv7e-m -mfloat-abi=hard -mfpu=fpv4-sp-d16\
 -mthumb -D__$(DEVICE)__ -DTARGET_IS_MSP432P4XX -Dgcc -g -gstrict-dwarf -Wall\
  -T$(LDDIR).lds -l'c' -l'gcc' -l'nosys'

# Uncomment when the precompiled library is used.
#LDFLAGS += -L$(TI_DRVLIB_LIB_DIR) -l'$(TI_DRVLIB_LIB)'
#======================= Source Files =======================s

PROJ_OUT = freertos_full_demo_gcc

STARTUP := $(DEMO_PATH)/startup_msp432p401r_gcc
SYSTEM := $(DEMO_PATH)/system_msp432p401r

OBJECTS +=  $(OUTPUT_DIR)/$(STARTUP).o
OBJECTS +=  $(OUTPUT_DIR)/$(SYSTEM).o

SRC_DIRS += $(DEMO_PATH)
SRC_DIRS += $(PORT_DEMO)

SRC_OS_DIRS += $(OS_SOURCE)
SRC_OS_DIRS += $(OS_PORT)
SRC_OS_DIRS += $(TI_DRVLIB_DIR)
SRC_OS_DIRS += $(FULL_DEMO_PATHS)

# Source files from C modules.
#SRC_FILES = $(wildcard ./*.c)
SRC_FILES += $(foreach dir,$(SRC_DIRS), $(wildcard $(dir)/*.c) $(wildcard $(dir)/*.C))

# Header files from C modules. 
HDR_FILES = $(foreach dir,$(SRC_DIRS), $(wildcard $(dir)/*.h))

# Source files from C modules.
SRC_OS_FILES = $(foreach dir,$(SRC_OS_DIRS), $(wildcard $(dir)/*.c) $(wildcard $(dir)/*.C))
#Add specific memory managr
SRC_OS_FILES += $(OS_MEM_MGR)
SRC_OS_FILES += $(FULL_DEMO_SRC_EXTRA)
SRC_OS_FILES += $(FULL_DEMO_SRC_MINIMAL)

# Header files from C modules. 
HDR_OS_FILES = $(foreach dir,$(SRC_OS_DIRS), $(wildcard $(dir)/*.h))

SRC_C_OBJS = $(patsubst %.c, %.o,$(SRC_FILES))

SRC_OS_C_OBJS = $(patsubst %.c, %.o,$(SRC_OS_FILES))

OBJ_DIRS = $(subst ./,$(OUTPUT_DIR)/,$(SRC_DIRS))
OBJ_OUT = $(subst ./,$(OUTPUT_DIR)/,$(SRC_C_OBJS))

OBJ_DIRS += $(subst ./,$(OUTPUT_DIR)/,$(SRC_OS_DIRS))
OBJ_OUT += $(subst ./,$(OUTPUT_DIR)/,$(SRC_OS_C_OBJS))

#Mem manager source was added manually. Do the same with Mem Manager dir.
OBJ_DIRS += $(subst ./,$(OUTPUT_DIR)/,$(OS_MEM_MGR_DIR))
OBJ_DIRS += $(subst ./,$(OUTPUT_DIR)/,$(FULL_DEMO_PATH_MINIMAL))
OBJ_DIRS += $(subst ./,$(OUTPUT_DIR)/,$(FULL_DEMO_SRC_EXTRA))

#======================= Rules =======================
all: $(OUTPUT_DIR) $(OUTPUT_DIR)/$(PROJ_OUT).out

$(PROJ_OUT): | $(OUTPUT_DIR)

$(OUTPUT_DIR):
	@$(MKDIR) $(OBJ_DIRS)
	@echo $(OBJ_DIRS)
	@echo ============================================
	@echo $(OBJ_OUT)

$(OUTPUT_DIR)/%.o : %.c
	@echo ============================================
	@echo Generating $@
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@	

$(OUTPUT_DIR)/$(PROJ_OUT).out : . $(OBJ_OUT)
	@echo ============================================
	@echo Linking objects and generating output binary
	$(CC) $(OBJ_OUT) $(LDFLAGS) -o $@ $(INCLUDES)


debug: all
	$(GDB) $(OUTPUT_DIR)/$(PROJ_OUT).out

clean:
	@echo "Cleaning project"
	@$(RM) $(OUTPUT_DIR)


