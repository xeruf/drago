PREFIX ?= /usr/local

.PHONY: build test install uninstall clean

build:
	swift build -c release --disable-sandbox

test:
	swift test

install: build
	install -d "$(PREFIX)/bin"
	install -m 755 "$$(swift build -c release --show-bin-path)/drago" "$(PREFIX)/bin/drago"

uninstall:
	rm -f "$(PREFIX)/bin/drago"

clean:
	swift package clean
