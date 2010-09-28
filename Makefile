all:
	chicken-install -no-install

install:
	chicken-install

uninstall:
	chicken-uninstall luup

clean:
	rm -f *.c *.o *.so *.import.scm

.PHONY: clean
