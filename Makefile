CC = clang
VERSION := $(shell cat VERSION)
LIBUSB_PREFIX := $(shell brew --prefix libusb)
CFLAGS = -Wall -Wextra -O2 -arch arm64 -mmacosx-version-min=26.0 -Iinclude -I$(LIBUSB_PREFIX)/include/libusb-1.0 -DVERSION=\"$(VERSION)\"
LDFLAGS = -arch arm64 -mmacosx-version-min=26.0 -L$(LIBUSB_PREFIX)/lib -lusb-1.0 -framework CoreFoundation -framework IOKit -framework Security -lobjc
SOURCES := $(wildcard src/*.c)
OBJECTS := $(patsubst src/%.c,build/%.o,$(SOURCES))
.PHONY: all clean package
all: build/android-tether
build:
	mkdir -p build
build/%.o: src/%.c | build
	$(CC) $(CFLAGS) -c $< -o $@
build/android-tether: $(OBJECTS)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
package:
	./packaging/build.sh
clean:
	rm -rf build dist
