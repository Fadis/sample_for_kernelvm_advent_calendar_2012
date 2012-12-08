# /*****************************************************************************
# * Copyright (C) 2012, Naomasa Matsubayashi                                  *
# * All rights reserved.                                                      *
# *                                                                           *
# * Redistribution and use in source and binary forms, with or without        *
# * modification, are permitted provided that the following conditions        *
# * are met:                                                                  *
# *                                                                           *
# * 1. Redistributions of source code must retain the above copyright         *
# *    notice, this list of conditions and the following disclaimer.          *
# * 2. Redistributions in binary form must reproduce the above copyright      *
# *    notice, this list of conditions and the following disclaimer in the    *
# *    documentation and/or other materials provided with the distribution.   *
# *                                                                           *
# * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR      *
# * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES *
# * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.   *
# * IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,          *
# * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT  *
# * NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, *
# * DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY     *
# * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT       *
# * (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF  *
# * THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.         *
# *                                                                           *
# *****************************************************************************/

PROGRAM          = fft
SATDIR           = /opt/sat/
BOOST_ROOT       = /opt/boost/1.52/

CXX		= $(SATDIR)/bin/arm-none-eabi-g++
LD		= $(SATDIR)/bin/arm-none-eabi-g++
OBJCOPY		= $(SATDIR)/bin/arm-none-eabi-objcopy

CFLAGS		= -O3 -Wall -Wextra -Werror \
		-fno-common -fno-use-cxa-atexit -mcpu=cortex-m4 -mtune=cortex-m4 -mthumb \
		-I$(SATDIR)/arm-none-eabi/include/ \
		-mfloat-abi=hard -mfpu=fpv4-sp-d16 -MD -DSTM32F4 -I$(BOOST_ROOT)/include
CXXFLAGS	= -std=c++0x -O3 -Wall -Wextra -Werror \
		-fno-common -fno-use-cxa-atexit -mcpu=cortex-m4 -mtune=cortex-m4 -mthumb \
		-I$(SATDIR)/arm-none-eabi/include/ \
		-mfloat-abi=hard -mfpu=fpv4-sp-d16 -MD -DSTM32F4 -I$(BOOST_ROOT)/include
LDSCRIPT	= ./stm32f4-discovery.ld
LDFLAGS		= --static -lopencm3_stm32f4 -lc -lnosys -lstdc++ \
		-L$(SATDIR)/arm-none-eabi/lib/thumb/cortex-m4/float-abi-hard/fpuv4-sp-d16/ \
		-L$(SATDIR)/arm-none-eabi/lib/ \
		-T$(LDSCRIPT) -nostartfiles -Wl,--gc-sections \
		-mthumb -mcpu=cortex-m4 -mfloat-abi=hard -mfpu=fpv4-sp-d16 \
		-lstdc++ -lm -lc -lnosys -lopencm3_stm32f4

all: $(PROGRAM).bin 

$(PROGRAM).bin: $(PROGRAM).elf
	$(OBJCOPY) -Obinary $(PROGRAM).elf $(PROGRAM).bin

$(PROGRAM).elf: main.o $(LDSCRIPT)
	$(LD) -o $(PROGRAM).elf main.o $(LDFLAGS)

main.o: main.cpp Makefile
	$(CXX) $(CXXFLAGS) -o main.o -c main.cpp
	$(CXX) $(CXXFLAGS) -o main.s -S main.cpp

clean:
	rm -f *.o
	rm -f *.d
	rm -f *.s
	rm -f *.elf
	rm -f *.bin


.PHONY: $(PROGRAM).bin clean

-include $(OBJS:.o=.d)

