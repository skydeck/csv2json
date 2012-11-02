csv2json: csv2json.ml
	ocamlfind opt -o $@ -package csv,yojson -linkpkg csv2json.ml

.PHONY: demo
demo: csv2json
	./csv2json -d TAB < freebase/freebase.csv | ydump

ifndef PREFIX
  PREFIX = $(HOME)
endif

ifndef BINDIR
  BINDIR = $(PREFIX)/bin
endif

.PHONY: install
install:
	cp csv2json $(BINDIR)

.PHONY: clean
clean:
	rm -f *.o *.cm* *~ csv2json
