.PHONY: deps
deps:
	@cargo install stylua --force

.PHONY: fmt
fmt:
	@stylua .

.PHONY: help
help:
	@echo "Usage: make [COMMAND]"
	@echo ""
	@echo "Commands:"
	@echo "  deps\t Install dependencies"
	@echo "  fmt\t Format init.lua"
