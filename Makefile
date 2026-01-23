# Options

BUILD ?= build


# Paths

SRCS_TRDL := $(shell find src/trdl -iname *.c*)
SRCS_ARDUINO := $(shell find src/arduino -iname *.c*)
SRCS_SERVER := $(shell find src/server -iname *.c*)
SRCS_CLIENT :=$(shell find src/client -iname *.c*)
SRCS_TEST := $(shell find src/tests -iname *.c*)

HDRS_TRDL := $(shell find src/trdl -iname *.h*)
HDRS_ARDUINO := $(shell find src/arduino -iname *.h*)
HDRS_SERVER := $(shell find src/server -iname *.h*)
HDRS_CLIENT := $(shell find src/client -iname *.h*)
HDRS_TEST := $(shell find src/tests -iname *.h*)

INO_ARDUINO := src/arduino/trdl/trdl.ino

OBJS_TEST := $(patsubst src/%.cpp,$(BUILD)/test/%.o,$(SRCS_TRDL) $(SRCS_CLIENT) $(SRCS_SERVER) $(SRCS_TEST))


# Tools

CXX := g++
CXXFLAGS := -std=c++11 -g3 -Os -Wall -Wextra -Werror
CXXFLAGS += -Wdouble-promotion -Wformat=2 -Wshadow -Wundef -Wunused
#CXXFLAGS += -Wconversion  # not supported by ETL
CXXFLAGS += -ffunction-sections -fno-common -fno-exceptions
CXXFLAGS += -DDOCTEST_CONFIG_NO_EXCEPTIONS_BUT_WITH_ALL_ASSERTS
CXXFLAGS += -I./lib -I./lib/etl/include
CXXFLAGS += -I./src/arduino -I./src/client -I./src/common -I./src/server -I./src/tests -I./src/trdl


# Commands for native

test: $(BUILD)/test/main
	$(BUILD)/test/main
.PHONY: test


# Commands for web

web:
.PHONY: web

serve:
.PHONY: serve


# Commands for Arduino

arduino: $(BUILD)/arduino/trdl/trdl.ino
.PHONY: arduino

upload: arduino
.PHONY: upload


# Recipes

$(BUILD)/arduino/trdl/%.ino: $(INO_ARDUINO) $(HDRS_ARDUINO) $(SRCS_ARDUINO) $(HDRS_TRDL) $(SRCS_TRDL)
	mkdir -p $(dir $@)
	cp $^ $(BUILD)/arduino/trdl

$(BUILD)/test/%.o: src/%.cpp $(HDRS_CLIENT) $(HDRS_SERVER) $(HDRS_TRDL) $(HDRS_TEST)
	mkdir -p $(dir $@)
	$(CXX) -o $@ -c $< $(CXXFLAGS)

$(BUILD)/test/main: $(OBJS_TEST)
	mkdir -p $(dir $@)
	$(CXX) -o $@ $^ $(CXXFLAGS)
