.PHONY: deps
deps:
	@cargo install stylua --force

.PHONY: format
format:
	@stylua .

.PHONY: help
help:
	@echo "Usage: make [COMMAND]"
	@echo ""
	@echo "Commands:"
	@echo "  deps\t Install dependencies"
	@echo "  format\t Format init.lua"
