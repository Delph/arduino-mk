# the file system image we're going to build
FILESYSTEM:=$(PROJECT_NAME).littlefs.bin

# the directory that'll be packed into the filesystem image
DATA_DIR?=data


# alias for the filesystem build
filesystem: $(FILESYSTEM)


$(FILESYSTEM): $(DATA_DIR)
	@test -n "$(MKLITTLEFS)" || (echo "MKLITTLEFS must be defined" >&2; exit 1)
	@test -n "$(FS_SIZE_KB)" || (echo "FS_SIZE_KB must be defined" >&2; exit 1)
	$(MKLITTLEFS) -c $(DATA_DIR) -s $(shell printf '%d' $$(( $(FS_SIZE_KB) * 1024 ))) $(FILESYSTEM)


# upload filesystem via over-the-air
ota-fs: $(FILESYSTEM)
	@test -n "$(OTA_TOOL)" || (echo "OTA_TOOL must be defined" >&2; exit 1)
	python3 $(OTA_TOOL) -i $(OTA_HOST) -p $(OTA_PORT) $(OTA_AUTH) -f $(FILESYSTEM) -s


CLEAN+=$(FILESYSTEM)


.PHONY: filesystem ota-fs
