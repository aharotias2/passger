all: $(shell ls -d src/*)
	valac --pkg=gtk+-3.0 $^ -o passger

make-desktop:
	bash make-desktop.sh

install: all make-desktop
	cp passger $(PREFIX)/bin
	cp passger.desktop $(PREFIX)/share/applications
