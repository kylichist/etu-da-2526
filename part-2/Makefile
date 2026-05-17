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
	@spin -a main.pml && gcc -w -o pan pan.c
	@echo "--- Property: mutex (взаимное исключение, не более K в КС) ---"
	@./pan -a -N mutex
	@echo "--- Property: bingate (gate остаётся бинарным) ---"
	@./pan -a -N bingate
	@echo "--- Property: binsem (S остаётся бинарным) ---"
	@./pan -a -N binsem
	@echo "--- Property: liveness (КС посещается бесконечно часто) ---"
	@./pan -a -f -N liveness

.PHONY: run-gui
run-gui:
	@echo "Running Main in Spin GUI..."
	@./ispin main.pml
