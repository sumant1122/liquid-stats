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
