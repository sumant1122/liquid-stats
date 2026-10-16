.PHONY: all build run stop clean

all: build

build:
	@./GlassHUD/build.sh

run: build
	@./run.sh

stop:
	@pkill -x GlassHUD 2>/dev/null && echo "GlassHUD stopped." || echo "GlassHUD is not running."

clean:
	@rm -rf build/ /tmp/clang-cache
	@echo "Cleaned build artifacts."

benchmark:
	@mkdir -p /tmp/clang-cache
	@swiftc -sdk /Library/Developer/CommandLineTools/SDKs/MacOSX26.5.sdk -module-cache-path /tmp/clang-cache -O Scripts/benchmark.swift -o /tmp/liquid-bench && /tmp/liquid-bench && rm -f /tmp/liquid-bench
