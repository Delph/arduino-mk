# install our core
core:
	@test -n "$(BOARD_MANAGER_URL)" || (echo "BOARD_MANAGER_URL must be defined" >&2; exit 1)
	@test -n "$(BOARD_CORE)" || (echo "BOARD_CORE must be defined" >&2; exit 1)
	-arduino-cli config init || true
	arduino-cli config add board_manager.additional_urls $(BOARD_MANAGER_URL)
	arduino-cli core update-index
	arduino-cli core install $(BOARD_CORE)


.PHONY: core
