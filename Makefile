.DELETE_ON_ERROR:

BABEL_OPTIONS = --stage 0
BIN           = ./node_modules/.bin
TESTS         = $(shell find src -path '*/__tests__/*-test.js')
SRC           = $(filter-out $(TESTS), $(shell find src -name '*.js'))
LIB           = $(SRC:src/%.js=lib/%.js) $(SRC:src/%.js=lib/%.js.flow)
NODE          = $(BIN)/babel-node $(BABEL_OPTIONS)

build:
	@$(MAKE) -j 8 $(LIB)

test::
	@$(BIN)/jest

ci::
	@$(BIN)/jest --watch

lint::
	@$(BIN)/flow

version-major version-minor version-patch: lint test
	@npm version $(@:version-%=%)

publish: build
	@git push --tags origin HEAD:master
	@npm publish --access public

lib/%.js: src/%.js
	@echo "Building $(@)"
	@mkdir -p $(@D)
	@$(BIN)/babel $(BABEL_OPTIONS) -o $@ $<

lib/%.js.flow: src/%.js
	@echo "Building $(@)"
	@mkdir -p $(@D)
	@cp $(<) $(@)

example: build
	@(cd example; $(BIN)/webpack --hide-modules)

watch-example: build
	@(cd example; $(BIN)/webpack --watch --hide-modules)

publish-example: build
	@(cd example;\
		rm -rf .git;\
		git init .;\
		$(BIN)/webpack -p;\
		git checkout -b gh-pages;\
		git add .;\
		git commit -m 'Update';\
		git push -f git@github.com:emreerdogan/react-fa.git gh-pages;\
	)

clean:
	@rm -rf lib
