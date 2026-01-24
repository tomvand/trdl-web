# Options

BUILD ?= build


# Paths

SRCS_COMMON := $(shell find src/common -iname *.c*)
SRCS_TRDL := $(shell find src/trdl -iname *.c*)
SRCS_ARDUINO := $(shell find src/arduino -iname *.c*)
SRCS_SERVER := $(shell find src/server -iname *.c*)
SRCS_CLIENT :=$(shell find src/client -iname *.c*)
SRCS_TEST := $(shell find src/tests -iname *.c*)

SRCS_ALL := $(SRCS_COMMON) $(SRCS_TRDL) $(SRCS_ARDUINO) $(SRCS_SERVER) $(SRCS_CLIENT) $(SRCS_TEST)

HDRS_COMMON := $(shell find src/common -iname *.h*)
HDRS_TRDL := $(shell find src/trdl -iname *.h*)
HDRS_ARDUINO := $(shell find src/arduino -iname *.h*)
HDRS_SERVER := $(shell find src/server -iname *.h*)
HDRS_CLIENT := $(shell find src/client -iname *.h*)
HDRS_TEST := $(shell find src/tests -iname *.h*)

HDRS_ALL := $(HDRS_COMMON) $(HDRS_TRDL) $(HDRS_ARDUINO) $(HDRS_SERVER) $(HDRS_CLIENT) $(HDRS_TEST)

INO_ARDUINO := src/arduino/trdl/trdl.ino

OBJS_TEST := $(patsubst src/%.cpp,$(BUILD)/test/%.o,$(SRCS_COMMON) $(SRCS_TRDL) $(SRCS_CLIENT) $(SRCS_SERVER) $(SRCS_TEST))


# Tools

CXX := g++
CXX_LIB_INCLUDE_FLAGS := -I./lib/buddy_alloc -I./lib/doctest/doctest -I./lib/etl/include
CXX_INCLUDE_FLAGS += -I./src/arduino -I./src/client -I./src/common -I./src/server -I./src/tests -I./src/trdl
CXXFLAGS := -std=c++11 -g3 -Os -Wall -Wextra -Werror
CXXFLAGS += -Wdouble-promotion -Wformat=2 -Wshadow -Wundef -Wunused
#CXXFLAGS += -Wconversion  # not supported by ETL
CXXFLAGS += -ffunction-sections -fno-common -fno-exceptions
CXXFLAGS += -DDOCTEST_CONFIG_NO_EXCEPTIONS_BUT_WITH_ALL_ASSERTS
CXXFLAGS += $(CXX_LIB_INCLUDE_FLAGS) $(CXX_INCLUDE_FLAGS)

CLANG_FORMAT ?= clang-format

CLANG_TIDY ?= clang-tidy
CLANG_TIDY_FLAGS := $(addprefix --extra-arg=, $(CXX_INCLUDE_FLAGS) $(CXX_LIB_INCLUDE_FLAGS))

CPPCHECK ?= cppcheck
CPPCHECK_FLAGS := \
	--enable=all \
	--std=c++11 \
	--inline-suppr \
	--suppressions-list=.suppress.cppcheck \
	$(CXX_INCLUDE_FLAGS)


# Editing commands

check: clang-tidy cppcheck clang-format-check
.PHONY: check

format: clang-format
.PHONY: format


# Individual editing tools

clang-format:
	$(CLANG_FORMAT) -i $(SRCS_ALL) $(HDRS_ALL)
.PHONY: clang-format

clang-format-check:
	$(CLANG_FORMAT) --dry-run --Werror $(SRCS_ALL) $(HDRS_ALL) || true
.PHONY: clang-format-check

clang-tidy:
	$(CLANG_TIDY) $(SRCS_ALL) $(CLANG_TIDY_FLAGS) || true
.PHONY: clang-tidy

cppcheck:
	$(CPPCHECK) $(CPPCHECK_FLAGS) $(SRCS_ALL) || true
.PHONY: cppcheck


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

$(BUILD)/arduino/trdl/%.ino: $(INO_ARDUINO) $(HDRS_ARDUINO) $(HDRS_COMMON) $(SRCS_ARDUINO) $(HDRS_TRDL) $(SRCS_TRDL)
	mkdir -p $(dir $@)
	cp $^ $(BUILD)/arduino/trdl

$(BUILD)/test/%.o: src/%.cpp $(HDRS_CLIENT) $(HDRS_COMMON) $(HDRS_SERVER) $(HDRS_TRDL) $(HDRS_TEST)
	mkdir -p $(dir $@)
	$(CXX) -o $@ -c $< $(CXXFLAGS)

$(BUILD)/test/main: $(OBJS_TEST)
	mkdir -p $(dir $@)
	$(CXX) -o $@ $^ $(CXXFLAGS)
