.PHONY: prerequisites
prerequisites:
	@echo "Installing dependent packages..."
	@sudo apt-get update
	@sudo apt-get install -y spin tcl tk graphviz wish
	@echo "Downloading Spin GUI..."
	@curl -o ispin https://raw.githubusercontent.com/nimble-code/Spin/refs/heads/master/optional_gui/ispin.tcl
	@chmod +x ispin

.PHONY: run
run:
	@echo "Verifying Main in Spin CLI..."
	@spin -a main.pml && gcc -w -o pan pan.c && ./pan

.PHONY: run-gui
run-gui:
	@echo "Running Main in Spin GUI..."
	@./ispin main.pml

.PHONY: run-helloworld
run-helloworld:
	@echo "Simulating Hello World in CLI..."
	@spin -V
	@spin helloworld.pml
