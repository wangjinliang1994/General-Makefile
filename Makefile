#编译目标
TARGET		:= demo
#TARGETA	:= libtest.a
#TARGETSO	:= libtest.so


DEVICE_USB	= n
UI			= y


#编译参数
PLATFORM	?= AI2
DEVICE		?= 9503
ifeq ($(PLATFORM), AI2)
$(warning PLATFORM = $(PLATFORM))
else
$(warning DEVICE = $(DEVICE))
endif

export PLATFORM
export DEVICE


#编译环境
CROSS_COMPILER	:=
G++			:= $(CROSS_COMPILER)g++
CC			:= $(CROSS_COMPILER)gcc
LD			:= $(CROSS_COMPILER)ld
AR			:= $(CROSS_COMPILER)ar
STRIP		:= $(CROSS_COMPILER)strip
OBJDUMP		:= $(CROSS_COMPILER)objdump


#编译选项
CFLAGS		:= -MMD -MP 
ifdef TARGETSO
CFLAGS		+= -fPIC
endif
CFLAGS		+= -O2
#CFLAGS		+= -Werror=return-type 
CFLAGS		+= -DDBG_MODE -DONVIF_SERVER -DOPENSSL -D_TEST


#编译链接
MAIN_DIR 	= $(shell pwd)
INCLUDE		:= -I.
LIBPATH		:= -L.
LIBS		:= -lpthread -lm -lrt -ldl
LIBPATH		+= -L$(MAIN_DIR)/lib
LIBS		+= -lixml -lthreadutil -lupnp -lcrypto -lssl


#编译文件
ALL_FILE	= y
ifeq ($(ALL_FILE), y)
outdirs		:= $(MAIN_DIR)/need-filter-out-dir
DIRS		:= $(filter-out $(outdirs),$(shell find $(MAIN_DIR) -maxdepth 9 -type d ! -path '*/.*'))
SRC			:= $(foreach dir, $(DIRS), $(wildcard $(dir)/*.c))
SRCPP		:= $(foreach dir, $(DIRS), $(wildcard $(dir)/*.cpp))
INCLUDE		+= $(foreach dir, $(DIRS), -I$(dir))
else
outobjs		:= $(MAIN_DIR)/need-filter-out-file
SRC			:= $(filter-out $(outobjs),$(wildcard $(MAIN_DIR)/*.c))  
SRCPP		:= $(filter-out $(outobjs),$(wildcard $(MAIN_DIR)/*.cpp))
include $(MAIN_DIR)/1/Makefile
include $(MAIN_DIR)/2/Makefile
include $(MAIN_DIR)/3/Makefile
endif

ifneq (,$(findstring $(DEVICE_USB), y Y))
$(warning DEVICE_USB = $(DEVICE_USB))
endif

ifneq (,$(findstring $(UI), y Y))
$(warning UI = $(UI))
endif


#编译文件改为*.o*.d的形式
OBJS		:= $(SRC:%.c=%.o) 
OBJS		+= $(SRCPP:%.cpp=%.o)
OBJS_D		:= $(OBJS:%.o=%.d)
-include $(OBJS_D)
OBJS_COUNT	:= $(words $(OBJS))


#声明标签,开始编译步骤
.PHONY  : all clean distclean help
.DEFAULT_GOAL := all

all:$(TARGET) $(TARGETA) $(TARGETSO)

#$(warning OBJS 	= $(OBJS))
$(warning LIBS  	= $(LIBS))
$(warning CFLAGS 	= $(CFLAGS))
#$(warning LIBPATH 	= $(LIBPATH))
#$(warning INCLUDE 	= $(INCLUDE))

$(TARGET): $(OBJS)
	@$(CC) -o $@ $^ $(LIBPATH) -Wl,--start-group $(LIBS) -Wl,--end-group
#	@$(STRIP) $(TARGET)
	@echo "TARGET building [$(TARGET)] successfully completed"

$(TARGETA): $(OBJS)
	@echo "TARGET building [$(TARGETA)] successfully completed"
	@$(AR) -crs $@ $^

$(TARGETSO): $(OBJS)
	@echo "TARGET building [$(TARGETSO)] successfully completed"
	@$(CC) -shared -o $@ $^

.c.o:
#	@printf "building %32s\n" $(notdir $@)
	@printf "[%d]building %*s%s\n" $(OBJS_COUNT) 4 "" $(subst $(MAIN_DIR)/, , $@)
	@$(CC) -c $(CFLAGS) $(INCLUDE) $< -o $@

.cpp.o:
#	@printf "building %32s\n" $(notdir $@)
	@printf "[%d]building %*s%s\n" $(OBJS_COUNT) 4 "" $(subst $(MAIN_DIR)/, , $@)
	@$(CC) -c $(CFLAGS) $(INCLUDE) $< -o $@

clean: 
	@rm -f $(TARGET) $(TARGETA) $(TARGETSO)
	@rm -f $(OBJS_D)
	@rm -f $(OBJS)

distclean:
	@rm -f $(TARGET) $(TARGETA) $(TARGETSO)
	@find . -name "*.d" -delete 2>/dev/null || true
	@find . -name "*.o" -delete 2>/dev/null || true

help:
	@echo "Usage:"
	@echo "  make             # Build all enabled targets"
	@echo "  make clean       # Remove object and dependency files"
	@echo "  make distclean   # Same as clean"
	@echo "  make help        # Show this message"



#CUR_PATH:= $(abspath $(lastword $(MAKEFILE_LIST)))
#CUR_DIR := $(patsubst %/, %, $(dir $(CUR_PATH)))

#DIRS = $(shell find $(CUR_DIR) -maxdepth 9 -type d ! -path '*/.*')


#SRC 	+= $(foreach dir, $(DIRS), $(wildcard $(dir)/*.c))
#SRCPP 	+= $(foreach dir, $(DIRS), $(wildcard $(dir)/*.cpp))

