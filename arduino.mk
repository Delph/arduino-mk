# resolve the project name from the directory
# the absolute project path
PROJECT_DIR:=$(dir $(abspath $(firstword $(MAKEFILE_LIST))))
# the project name (the directory name)
PROJECT_NAME:=$(notdir $(patsubst %/,%,$(PROJECT_DIR)))

ARDUINO_MK_DIR:=$(dir $(abspath $(lastword $(MAKEFILE_LIST))))

# Arduino projects need a root .ino file
SKETCH_FILE:=$(PROJECT_NAME).ino


# the build directory is what is passed to arduino-cli
BUILD_DIR?=build

# optional compiler flags and upload port override
DEFINES?=
PORT?=


# search is a recursive function to find files with a particular extension
# this is better than wildcard, as wildcard is non-recursive
search = $(foreach item,$(wildcard $(1)/*),$(if $(wildcard $(item)/.),$(call search,$(item),$(2)),$(if $(filter %$(2),$(item)),$(item))))


# the binary that arduino-cli will build
FIRMWARE:=$(BUILD_DIR)/$(PROJECT_NAME).ino.bin
# the source files we need to buid, the main file (which should stay empty), and all source files
# arduino-cli doesn't need this, but providing it to make allows us to rebuild only when necessary
SOURCES:=$(SKETCH_FILE) $(call search,src,.cpp) $(call search,src,.h)


# the baud rate for the serial monitor
BAUD_RATE?=115200


# alias for the build target
compile: $(FIRMWARE)


# build the binary to upload, which depends on our sources
$(FIRMWARE): $(SOURCES)
	@test -n "$(FQBN)" || (echo "FQBN must be defined" >&2; exit 1)
	arduino-cli compile --fqbn $(FQBN) --build-path $(BUILD_DIR) --build-property compiler.cpp.extra_flags="$(DEFINES)" $(SKETCH_FILE)
	@cp $(BUILD_DIR)/compile_commands.json compile_commands.json


# upload the compiled binary to the device
upload: $(FIRMWARE)
	@test -n "$(FQBN)" || (echo "FQBN must be defined" >&2; exit 1)
	arduino-cli upload --fqbn $(FQBN) --port="$$(PORT=$(PORT) $(ARDUINO_MK_DIR)detect-port)" --input-dir $(BUILD_DIR)


# run the serial monitor
monitor:
	arduino-cli monitor -p "$$(PORT=$(PORT) $(ARDUINO_MK_DIR)detect-port)" --config $(BAUD_RATE) --timestamp


# targets which need a port should depend on this target, can also be used to check the port
port:
	@PORT=$(PORT) $(ARDUINO_MK_DIR)detect-port


# install libraries
libraries:
	@test -n "$(LIBRARIES)" || (echo "No libraries configured"; exit 0)
	arduino-cli lib install $(LIBRARIES)


# clean up, should remove any and all build artefacts
clean:
	@$(RM) -rf $(BUILD_DIR) compile_commands.json $(CLEAN)


.PHONY: clean compile monitor port libraries
