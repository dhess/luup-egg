all:	install

install:
	chicken-install

build:
	chicken-install -no-install

uninstall:
	chicken-uninstall luup
	chicken-uninstall run-scene
	chicken-uninstall scene-status

clean:
	rm -f *.c *.o *.so *.import.scm

.PHONY: clean
