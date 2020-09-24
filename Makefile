.PHONY: all

CONSOLE := docker-compose run --rm console

all:
	@echo "Use \"make help\" to list available commands"

help:
	@echo "Available commands:"
	@echo "  container           Build docker container"
	@echo "  list                List installed arduino cores"
	@echo "  [new project name]  Create new project"
	@echo
	@echo "Examples:"
	@echo "  make blink"

container:
	docker-compose build

list:
	$(CONSOLE) arduino-cli core list

boardlist:
	$(CONSOLE) arduino-cli board listall

build upload clean monitor proglist:
	@echo "Run in project directory"

details:
	@echo $(if $(name),"Details for $(name)","Details for arduino:avr:nano. Use \`make details name=<board name>\` for another board details. Use \`make boardlist\` to get a list of available boards")
	$(CONSOLE) arduino-cli board details --fqbn$(if $(name), $(name), arduino:avr:nano)

console:
	$(CONSOLE)

%:
	$(CONSOLE) arduino-cli sketch new "$@"
	sudo chown -R $(shell whoami) "$@"
	cp Makefile.sample "$@/Makefile"
	cp sketch.json.sample "$@/sketch.json"
	echo 'build/' >> "$@/.gitignore"
