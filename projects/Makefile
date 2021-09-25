MAKEFLAGS += --silent

ifeq (,$(wildcard ./sketch.json))
	exit 1
endif

PROJECT_NAME ?= $(shell basename $(shell pwd))
DEVPORT ?= $(shell ls /dev | grep ttyUSB | sort | tail -1)
CONSOLE := docker-compose run -w /app/projects/$(PROJECT_NAME) --rm console
CONSOLE_WDEV := docker-compose -f ../../docker-compose.yml -f docker-compose.devices.yml run -w /app/projects/$(PROJECT_NAME) --rm console
FQBN := $(shell cat sketch.json | grep fqbn | cut -d'"' -f4)
PROG ?= $(shell cat sketch.json | grep programmer | cut -d'"' -f4) # Use "make board details" to list programmers

export FQBN

all: build upload clean

help:
	@echo "Available commands:"
	@echo "  build                             Build project"
	@echo "  clean                             Clean build artifacts"
	@echo "  upload                            Upload code to board"
	@echo "  bootloader                        Burn bootloader"
	@echo
	@echo "  monitor                           Serial monitor"
	@echo "  proglist                          List programmers"
	@echo
	@echo "  board details [name=<FQBN>]       Board details"
	@echo "$$CLI_HELP"

build:
	 $(CONSOLE) arduino-cli compile -v --build-cache-path /app/.cache --fqbn $(FQBN)

upload flash: docker-compose.devices.yml pause_monitor
ifndef DEVPORT
	@echo "Device port not found"
else
ifneq ($(strip $(PROG)),)
	$(eval PROGRAMMER := --programmer $(PROG))
endif
	$(CONSOLE_WDEV) arduino-cli upload -v -p /dev/$(DEVPORT) --fqbn $(FQBN) $(PROGRAMMER)
	rm docker-compose.devices.yml
endif
	$(MAKE) unpause_monitor

clean:
	$(CONSOLE) rm -fr build/ docker-compose.devices.yml

proglist:
	$(CONSOLE) arduino-cli upload --programmer list --fqbn $(FQBN)

bootloader: docker-compose.devices.yml
ifndef DEVPORT
	@echo "Device port not found"
else
	$(CONSOLE_WDEV) arduino-cli burn-bootloader -v -p $(DEVPORT) --programmer $(PROG) --fqbn $(FQBN)
	rm docker-compose.devices.yml
endif

monitor: docker-compose.devices.yml
ifndef DEVPORT
	@echo "Device port not found"
else
	$(eval BAUDRATE ?= $(shell cat sketch.json | grep baudrate | cut -d':' -f2))
	$(CONSOLE_WDEV) python3 -m serial.tools.miniterm /dev/$(DEVPORT) $(BAUDRATE)
	rm docker-compose.devices.yml
endif

MONITOR_CONTAINER := $(shell docker ps | grep arduino | grep python)

pause_monitor:
ifneq ($(strip $(MONITOR_CONTAINER)),)
ifeq ($(findstring Paused,$(MONITOR_CONTAINER)),)
	docker pause $(word 1,$(MONITOR_CONTAINER))
endif
endif

unpause_monitor:
ifneq ($(strip $(MONITOR_CONTAINER)),)
ifeq ($(findstring Paused,$(MONITOR_CONTAINER)),Paused)
	docker unpause $(word 1,$(MONITOR_CONTAINER))
endif
endif

console:
	$(CONSOLE)
