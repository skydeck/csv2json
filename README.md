csv2json
========

Convert a CSV file with a header containing the field names into
JSON records, one per line, omitting empty fields.

Installation
------------

Requires OCaml, ocamlfind (Findlib),
[csv](https://forge.ocamlcore.org/projects/csv/)
and [yojson](https://github.com/mjambon/yojson).

```
$ make
$ make install
```

Also supports `make PREFIX=... install` and `make BINDIR=... install`.
