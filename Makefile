SRC = $(shell find ./src/*)

passger: $(SRC)
	valac --pkg=gtk+-3.0 $^ -o passger

.PHONY: install

install: passger
	install --strip --mode=755 passger $(PREFIX)/bin
	install data/passger.desktop $(PREFIX)/share/applications

.PHONY: clean

clean:
	rm passger

