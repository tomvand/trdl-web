BUILD ?= build

CMAKE ?= $(shell command -v cmake)
CMAKE_QUIET := -- --quiet


# Commands

clean:
	rm -r $(BUILD) || true
.PHONY: clean

configure: $(BUILD)
.PHONY: configure

check: configure
	$(CMAKE) --build $(BUILD) --target check $(CMAKE_QUIET)

test: configure
	$(CMAKE) --build $(BUILD) --target run-tests $(CMAKE_QUIET)
.PHONY: test


# Recipes

$(BUILD): CMakeLists.txt
	$(CMAKE) -S . -B $(BUILD)
	touch $(BUILD)
