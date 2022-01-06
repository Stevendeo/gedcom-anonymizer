# Generated by "drom project"
.PHONY: all build build-deps fmt fmt-check install dev-deps test
.PHONY: clean distclean

DEV_DEPS := merlin ocamlformat odoc ppx_expect ppx_inline_test


SPHINX_TARGET:=_drom/docs/sphinx

ODOC_TARGET:=_drom/docs/doc/.


all: build

build:
	./scripts/before.sh build
	opam exec -- dune build @install
	./scripts/copy-bin.sh gedcom-anonymizer gedcom_anonymizer_lib
	./scripts/after.sh build

build-deps:
	if ! [ -e _opam ]; then \
	   opam switch create . 4.10.0 ; \
	fi
	opam install ./*.opam --deps-only


.PHONY: doc-common odoc view sphinx
doc-common: build
	mkdir -p _drom/docs
	rsync -auv docs/. _drom/docs/.

sphinx: doc-common
	./scripts/before.sh sphinx ${SPHINX_TARGET}
	sphinx-build sphinx ${SPHINX_TARGET}
	./scripts/after.sh sphinx  ${SPHINX_TARGET}

odoc: doc-common
	mkdir -p ${ODOC_TARGET}
	./scripts/before.sh odoc ${ODOC_TARGET}
	opam exec -- dune build @doc
	rsync -auv --delete _build/default/_doc/_html/. ${ODOC_TARGET}
	./scripts/after.sh odoc ${ODOC_TARGET}

doc: doc-common odoc sphinx

view:
	xdg-open file://$$(pwd)/_drom/docs/index.html

fmt:
	opam exec -- dune build @fmt --auto-promote

fmt-check:
	opam exec -- dune build @fmt

install:
	opam pin -y --no-action -k path .
	opam install -y .

opam:
	opam pin -k path .

uninstall:
	opam uninstall .

dev-deps:
	opam install ./*.opam --deps-only --with-doc --with-test

test:
	./scripts/before.sh test
	opam exec -- dune build @runtest
	./scripts/after.sh test

clean:
	rm -rf _build
	./scripts/after.sh clean

distclean: clean
	rm -rf _opam _drom
	./scripts/after.sh distclean


