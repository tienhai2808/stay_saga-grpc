.PHONY: github proto-gen

proto-gen:
	@test -n "$(PROTO)" || { echo "Usage: make proto-gen PROTO=Protos/<file>.proto PROTO_ROOT=Protos OUT=Protos/Gen/<Domain> [GRPC_PLUGIN=/abs/path/to/grpc_csharp_plugin]"; exit 1; }
	@test -n "$(PROTO_ROOT)" || { echo "Missing PROTO_ROOT"; exit 1; }
	@test -n "$(OUT)" || { echo "Missing OUT"; exit 1; }
	@mkdir -p "$(OUT)"
	@command -v protoc >/dev/null 2>&1 || { echo "Missing protoc in PATH"; exit 1; }
	@test -f "$(PROTO)" || { echo "Missing proto file: $(PROTO)"; exit 1; }
	@PLUGIN="$(GRPC_PLUGIN)"; \
	if [ -z "$$PLUGIN" ] || ! command -v "$$PLUGIN" >/dev/null 2>&1; then \
		PLUGIN="$$(ls -1d $$HOME/.nuget/packages/grpc.tools/*/tools/linux_x64/grpc_csharp_plugin 2>/dev/null | sort -V | tail -n 1)"; \
	fi; \
	if [ -z "$$PLUGIN" ]; then \
		echo "Missing grpc plugin. Set GRPC_PLUGIN=/abs/path/to/grpc_csharp_plugin"; \
		exit 1; \
	fi; \
	protoc \
		--proto_path="$(PROTO_ROOT)" \
		--csharp_out="$(OUT)" \
		--grpc_out="$(OUT)" \
		--plugin=protoc-gen-grpc="$$PLUGIN" \
		"$(PROTO)"

github:
	@if [ -z "$(CM)" ]; then \
		echo "Usage: make github CM=\"commit message\""; \
		exit 1; \
	fi
	git add .
	git commit -m "$(CM)"
	git push origin main
