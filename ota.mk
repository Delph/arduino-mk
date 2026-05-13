# the hostname of the device we want to upload to
OTA_HOST?=$(PROJECT_NAME).lan

# the port we want to connect to upload, defaults to ESP8266 port
OTA_PORT?=8266

# the auth argument, if required
OTA_AUTH:=$(if $(OTA_PASS),-a $(OTA_PASS),)


# upload firmware over-the-air
ota: $(FIRMWARE)
	@test -n "$(OTA_TOOL)" || (echo "OTA_TOOL must be defined" >&2; exit 1)
	python3 $(OTA_TOOL) -i $(OTA_HOST) -p $(OTA_PORT) $(OTA_AUTH) -f $(FIRMWARE)


.PHONY: ota
