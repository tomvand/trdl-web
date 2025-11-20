# Options

BUILD ?= build


# Paths

SRCS_TRDL := $(wildcard src/trdl/*.cpp)
SRCS_ARDUINO := $(wildcard src/arduino/*.cpp)
SRCS_SERVER := $(wildcard src/server/*.cpp)
SRCS_CLIENT :=$(wildcard src/client/*.cpp)
SRCS_TEST := $(wildcard src/tests/*.cpp)

HDRS_TRDL := $(wildcard src/trdl/*.hpp)
HDRS_ARDUINO := $(wildcard src/arduino/*.hpp)
HDRS_SERVER := $(wildcard src/server/*.hpp)
HDRS_CLIENT := $(wildcard src/client/*.hpp)
HDRS_TEST := $(wildcard src/tests/*.hpp)

INO_ARDUINO := src/arduino/trdl/trdl.ino

OBJS_TEST := $(patsubst src/%.cpp,$(BUILD)/test/%.o,$(SRCS_TRDL) $(SRCS_CLIENT) $(SRCS_SERVER) $(SRCS_TEST))


# Tools

CXX := g++
CXXFLAGS := -std=c++11 -Wall -Wextra -Werror -O2
CXXFLAGS += -I./src/arduino -I./src/client -I./src/server -I./src/tests -I./src/trdl


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
