.PHONY: build test lint-check lint install doc release clean

ifeq ($(CONFIG),)
CONFIG:=Debug
endif

JOBS:=4
BUILD_DIR:=build/$(CONFIG)
INSTALL_DIR:=install/$(CONFIG)
CMAKE_OPTS:=-S. -B$(BUILD_DIR) \
	-DCMAKE_INSTALL_PREFIX=$(INSTALL_DIR) \
	-DCMAKE_BUILD_TYPE=$(CONFIG) \
	-DCMAKE_EXPORT_COMPILE_COMMANDS=1 \
	-DENABLE_TEST_COVERAGE=1

export VERBOSE=1
export CPM_SOURCE_CACHE=$(HOME)/.cache/cpm

.DEFAULT_GOAL=test

$(BUILD_DIR):
	cmake $(CMAKE_OPTS)
	rm -f compile_commands.json && ln -sf $(BUILD_DIR)/compile_commands.json compile_commands.json

$(INSTALL_DIR): $(BUILD_DIR)
	cmake --build $(BUILD_DIR) --target install -- -j $(JOBS)

build: $(BUILD_DIR)
	cmake --build $(BUILD_DIR) -- -j $(JOBS)

test: $(BUILD_DIR) build
	cmake --build $(BUILD_DIR) --target test

lint-check: $(BUILD_DIR)
	cmake --build $(BUILD_DIR) --target check-format

lint: $(BUILD_DIR)
	cmake --build $(BUILD_DIR) --target fix-format

install: test
	cmake --build $(BUILD_DIR) --target install -- -j $(JOBS)

doc:
	cmake -S documentation -B $(BUILD_DIR)/doc
	cmake --build $(BUILD_DIR)/doc --target GenerateDocs
	# open $(BUILD_DIR)/doc/doxygen/html/index.html

release:
	env CONFIG=RelWithDebInfo sh -c "make test && make install"

clean:
	rm -fr $(BUILD_DIR) $(INSTALL_DIR)
