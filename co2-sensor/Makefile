PROJECT ?= $(shell basename $(shell pwd))
CONSOLE := docker-compose run --rm -w /app/$(PROJECT) console
ARDUCLI := $(CONSOLE) arduino-cli --config-file /app/arduino-cli.yaml
DEVPORT := $(shell cat sketch.json | grep port | cut -d'"' -f4)
FQBN := $(shell cat sketch.json | grep fqbn | cut -d'"' -f4)
PROG ?= $(shell cat sketch.json | grep programmer | cut -d'"' -f4) # Use "make proglist" to list programmers

all: build upload clean

help:
	@echo "Available commands:"
	@echo "  boardlist             List boards"
	@echo "  bootloader            Burn bootloader"
	@echo "  details [name=<FQBN>] Board details"
	@echo ""
	@echo "  build                 Build project"
	@echo "  clean                 Clean build artifacts"
	@echo "  upload                Upload code to board"
	@echo ""
	@echo "  console               Docker container shell"
	@echo "  proglist              List programmers"

build:
	 $(ARDUCLI) compile -v --build-cache-path /app/.cache

upload:
	$(ARDUCLI) upload -v -p $(DEVPORT) $(if $(PROG),--programmer $(PROG),)

clean:
	$(CONSOLE) rm -r build/

boardlist:
	$(ARDUCLI) board listall

details:
	$(eval name ?= $(shell echo $(FQBN) | cut -d: -f1-3))
	$(ARDUCLI) board details $(name)

proglist:
	$(ARDUCLI) upload --programmer list --fqbn $(FQBN)

bootloader:
	$(ARDUCLI) burn-bootloader -v -p $(DEVPORT) --programmer $(PROG) --fqbn $(FQBN)

console:
	$(CONSOLE)
