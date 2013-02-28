.PHONY: all
all: csv2json json2csv

csv2json: csv2json.ml
	ocamlfind opt -o $@ -package csv,yojson -linkpkg csv2json.ml

json2csv: json2csv.ml
	ocamlfind opt -o $@ -package csv,yojson -linkpkg json2csv.ml

.PHONY: demo
demo: csv2json json2csv
	./csv2json -d TAB < freebase/freebase.csv | ydump > freebase.json
	cat freebase.json
	./json2csv name nationality < freebase.json

ifndef PREFIX
  PREFIX = $(HOME)
endif

ifndef BINDIR
  BINDIR = $(PREFIX)/bin
endif

.PHONY: install
install:
	cp csv2json json2csv $(BINDIR)

.PHONY: clean
clean:
	rm -f *.o *.cm* *~ csv2json json2csv freebase.json
