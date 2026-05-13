# arduino-mk
A collection of Makefiles around the `arduino-cli` tool to make building and managing Arduino projects simpler.


## Usage
Initialise the repository as a submodule of your Arduino project;
```bash
git submodule add git@github.com:Delph/arduino-mk.git arduino-mk
```

Setup your project as a standard Arduino project, the file structure should look like;
```
project
├── arduino-mk
│   └── ...
├── project.ino
└── src
    ├── inputs.cpp
    ├── inputs.h
    └── main.cpp
```

Create a minimal `Makefile` in the project's root;
```Makefile
FQBN:=arduino:avr:nano

include arduino-mk/arduino.mk
```

Then you can use various targets to compile, upload, watch the serial monitor, etc;
```bash
# compile your Arduino project
make compile

# if your project sets .DEFAULT_GOAL:=compile, this is equivalent to make compile
make

# upload the compiled firmware to the board
make upload

# open the serial monitor
make monitor
```

The root `.ino` file must match the project directory name. For example, a project in `project/` should contain `project.ino`.

You can override the detected upload/monitor port if needed;
```bash
make upload PORT=/dev/ttyUSB0
make monitor PORT=/dev/ttyUSB0
```

You can also configure the serial monitor baud rate and compiler defines from your project `Makefile`;
```Makefile
BAUD_RATE:=9600
DEFINES:=-DDEBUG=1
```

### Libraries
If your project needs third-party libraries, you can add a `LIBRARIES` definition to your Makefile;
```Makefile
FQBN:=arduino:avr:nano
LIBRARIES:=FastLED

include arduino-mk/arduino.mk
```
and then run `make libraries` to install them

### Alternative Cores
Similarly to libraries, defining `BOARD_MANAGER_URL` and `BOARD_CORE`, and including `arduino-mk/core.mk` allows you to set up for alternative microcontrollers that support Arduino.
For example, an ESP8266;
```Makefile
BOARD_MANAGER_URL:=https://arduino.esp8266.com/stable/package_esp8266com_index.json
BOARD_CORE:=esp8266:esp8266
FQBN:=esp8266:esp8266:generic:eesz=1M128


include arduino-mk/arduino.mk
include arduino-mk/core.mk
```

Then run `make core` to install the core, and then all the normal workflow works as normal.


### OTA
`ota.mk` provides targets for Over-The-Air updates for ESP tools.
You'll need to define the `OTA_TOOL` variable and include the `ota.mk` file;
```Makefile
OTA_TOOL:=$(HOME)/.arduino15/packages/esp8266/hardware/esp8266/3.1.2/tools/espota.py

# ...

include arduino-mk/ota.mk

```

This'll give you an `ota` target, which can be used to upload code. You may need to set OTA parameters;
- `OTA_HOST` - Defaults to `<project>.lan`
- `OTA_PORT` - Defaults to `8266`
- `OTA_PASS` - Defaults to blank (no authorisation).


### LittleFS
`littlefs.mk` provides targets for building filesystem images.
You'll need to define the `MKLITTLEFS` variable, and include the `littlefs.mk` file;
```Makefile
MKLITTLEFS:=$(firstword $(wildcard $(HOME)/.arduino15/packages/esp8266/tools/mklittlefs/*/mklittlefs))

# ...

include arduino-mk/littlefs.mk
```

This will give you a `filesystem` target, which can be used to build a file system image (`<project>.littlefs.bin` by default).
You must set the filesystem size, and may set the data directory;
- `DATA_DIR` - The directory to build the filesystem image from, defaults to `data`.
- `FS_SIZE_KB` - The size the filesystem image should be on flash, in KB.

This will also give you an `ota-fs` target, which you can use to upload the filesystem over-the-air, but you'll need OTA configured as well.

## Inclusion order
Include `arduino.mk` first, followed by whichever optional makefiles your project needs;
```Makefile
include arduino-mk/arduino.mk
include arduino-mk/core.mk      # optional
include arduino-mk/ota.mk       # optional
include arduino-mk/littlefs.mk  # optional
```
