NODE_BIN=./node_modules/.bin
BSB=$(NODE_BIN)/bsb

.PHONY: deps
deps:
	@yarn

.PHONY: docs
docs: build
	@./scripts/mk-docs.sh ReActor ./lib/bs/src ./src "*.cmti"
	@./scripts/mk-docs.sh Examples ./lib/bs/examples ./examples "*.cmt"

.PHONY: spec-docs
spec-docs:
	@./scripts/setup-tla-plus.sh
	@./scripts/tla-to-pdf.sh

.PHONY: build
build: deps
	@$(BSB) -make-world

.PHONY: world
world: deps
	@$(BSB) -make-world -w

.PHONY: fmt
fmt: deps
	@$(NODE_BIN)/bsrefmt --in-place ./src/*.re ./src/*.rei ./examples/**/*.re

.PHONY: bench
bench:
	@node lib/js/bench/Bench.bs.js

.PHONY: test
test:
	@node lib/js/test/Test.bs.js

.PHONY: serve
serve: deps
	rm -f ./reactor
	ln -sf ./docs/ ./reactor
	@$(NODE_BIN)/static

.PHONY: clean
clean:
	@$(BSB) -clean-world

.PHONY: cleanall
cleanall: clean
	@rm -rf node_modules lib
