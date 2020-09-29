.PHONY: all

CONSOLE := docker-compose run -w /app/projects --rm console
MAKEFLAGS += --silent

all:
	@echo "Use \"make help\" to list available commands"

help:
	@echo "Available commands:"
	@echo "  container                         Build docker container"
	@echo "  project name=<project name>       Create new project"
	@echo
	@echo "$$CLI_HELP"
	@echo
	@echo "Examples:"
	@echo "  make project name=blink"

container:
	docker-compose build

console:
	$(CONSOLE)

project:
ifndef name
	@echo "Usage: make $@ name=<project name>"
else
ifneq ($(shell ls | grep $(name)),"")
	$(CONSOLE) arduino-cli sketch new "$(name)"
	$(CONSOLE) chown -R $(shell echo $$UID) "$(name)"
	echo "include ../Makefile.cli" > "projects/$(name)/Makefile"
	echo "include ../Makefile" >> "projects/$(name)/Makefile"
	cp projects/sketch.sample "projects/$(name)/sketch.json"
	echo 'build/' > "projects/$(name)/.gitignore"
	echo "# $(name)" >> "projects/$(name)/README.md"
else
	@echo "Project already exists"
endif
endif

include projects/Makefile.cli

build upload flash clean monitor proglist:
	@echo "Run in project directory"
