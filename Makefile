.PHONY: all core

CONSOLE := docker-compose run -w /app/projects --rm console
# MAKEFLAGS += --silent

all:
	@echo "Use \"make help\" to list available commands"

help:
	@echo "Available commands:"
	@echo "  board search [name=<board name>]  Search arduino boards"
	@echo
	@echo "  container                         Build docker container"
	@echo
	@echo "  core install name=<core name>     Install arduino core"
	@echo "  core list                         List installed arduino cores"
	@echo "  core search [name=<core name>]    Search arduino cores"
	@echo "  core uninstall [name=<core name>] Uninstall arduino cores"
	@echo
	@echo "  lib install name=<lib name>       Install arduino lib"
	@echo "  lib list                          List installed arduino libs"
	@echo "  lib search [name=<lib name>]      Search arduino libs"
	@echo
	@echo "  upgrade                           Upgrade arduino cores & libs"
	@echo
	@echo "  project name=<project name>       Create new project"
	@echo
	@echo "Examples:"
	@echo "  make project name=blink"

container:
	docker-compose build

core lib board:
	$(MAKE) $(shell echo $(MAKECMDGOALS) | tr ' ' _)$(if $(name), name="$(name)",)

core_list core_search core_install core_upgrade core_uninstall lib_list lib_search lib_install lib_upgrade:
ifneq ($(MAKECMDGOALS:search=), $(MAKECMDGOALS))
	@echo "Use \`make core search name=<core name>\` to filter search results"
	@echo
endif
ifneq ($(MAKECMDGOALS:install=), $(MAKECMDGOALS))
ifdef name
	$(eval CHOWN := 1)
else
	@echo "Use \`make core install name=<core name>\`. Use \`make core search\` to search available cores"
	@echo
  $(eval IGNORE := 1)
endif
endif
ifndef IGNORE
	$(CONSOLE) arduino-cli $(shell echo $@ | tr _ ' ')$(if $(name), "$(name)",)
	$(if $(CHOWN),$(CONSOLE) chown -R $(shell echo $$UID) ../vendor/,)
endif

board_search:
	$(CONSOLE) arduino-cli board listall$(if $(name), | grep $(name),)

build upload clean monitor proglist:
	@echo "Run in project directory"

details:
	@echo $(if $(name),"Details for $(name)","Details for arduino:avr:nano. Use \`make details name=<board name>\` for another board details. Use \`make boardlist\` to get a list of available boards")
	$(CONSOLE) arduino-cli board details --fqbn$(if $(name), $(name), arduino:avr:nano)

console:
	$(CONSOLE)

project:
ifndef name
	@echo "Usage: make $@ name=<project name>"
else
	$(CONSOLE) arduino-cli sketch new "$@"
	sudo chown -R $(shell echo $$UID) "$@"
	cp ../Makefile.sample "$@/Makefile"
	cp ../sketch.json.sample "$@/sketch.json"
	echo 'build/' >> "$@/.gitignore"
endif

list install uninstall search:

upgrade:
ifeq ($(MAKECMDGOALS), upgrade)
	$(MAKE) core_upgrade lib_upgrade
endif
