all:	install

install:
	chicken-install

build:
	chicken-install -no-install

uninstall:
	chicken-uninstall -force luup
	chicken-uninstall -force run-scene
	chicken-uninstall -force scene-status

clean:
	rm -f *.c *.o *.so *.import.scm

.PHONY: clean
