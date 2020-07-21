.POSIX:
.PHONY: clean compile native all
.SUFFIXES: .el .elc .eln

SRCS := $(wildcard *.el)

LISPINCL ?= $(addprefix -L ,${HOME}/.emacs.d/lisp)
LISPINCL += -L .
LISPINCL += $(addprefix -L ,${HOME}/.emacs.d/elpa/sauron-*)

INSTALELN ?= $(${HOME}/.emacs.d/lisp/eln-*)

ifeq ($(PREFIX),)
    PREFIX := ${HOME}/.emacs.d/
endif

EM = emacs --batch
CP = cp

all: fix-cl compile

%.elc: %.el
	$(EM) $(LISPINCL) -f batch-byte-compile $<

.elc.eln:
	$(EM) $(LISPINCL) --eval '(native-compile "$<")'

fix-cl:
	./bash-fix-old-cl.sh

compile: fix-cl ${patsubst %.el, %.elc, $(SRCS)}

native: ${patsubst %.el, %.eln, $(SRCS)}

install:
	mkdir -p $(DESTDIR)$(PREFIX)/lisp
	$(CP) *.el $(DESTDIR)$(PREFIX)/lisp
	$(CP) *.elc $(DESTDIR)$(PREFIX)/lisp

install-native:
	$(CP) eln-*/* $(DESTDIR)$(PREFIX)/lisp/eln-*

install-all: install install-native

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/lisp/ne2wm-*

uninstall-native:
	rm -f $(DESTDIR)$(PREFIX)/lisp/eln-*/ne2wm-*


uninstall-all: uninstall uninstall-native

clean:
	rm -rf *.elc eln-*

