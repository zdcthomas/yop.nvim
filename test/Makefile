SPEC=

RUN=nvim --headless --noplugin -u spec.lua

.PHONY: all nvim test watch prepare

prepare:
	git submodule update --depth 1 --init
	luarocks install luacheck --local

nvim:
	@nvim --noplugin -u spec.lua

lint:
	luacheck ../lua/ ./spec/

test:
ifeq ($(strip $(SPEC)),) # a.k.a. $(SPEC) is empty
	@$(RUN) -c "PlenaryBustedDirectory spec/ { minimal_init = 'spec.lua' }"
else
	@$(RUN) -c "PlenaryBustedFile $(SPEC)"
endif

watch:
	@echo -e '\nRunning tests on "spec/**/*_spec.lua" when any Lua file on "../lua/" and "spec/" changes\n'
	@find spec/ ../lua/ -name '*.lua' \
	  | entr make test SPEC=$(SPEC)

all: prepare test lint
