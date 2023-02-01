# this file referenced via an `include` statement in the `Makefile`s within the various UGx directories

languages = en ja cn
formats = html pdf

# you can override on command line
lang = en

html: $(lang)/html
html-finalize: $(lang)/html-finalize
pdf: $(lang)/pdf
pdf-finalize: $(lang)/pdf-finalize
clean: $(lang)/clean
pot: en/pot

known-targets := $(foreach l,$(languages),$(addprefix $(l)/,$(formats)))
known-targets += $(addsuffix -finalize,$(known-targets))
# clean targets
clean-targets += $(foreach l,$(languages),$(addprefix $(l)/,clean))
known-targets += $(clean-targets)
# pot targets
known-targets += en/pot

$(known-targets):
	make -C $(@D) $(@F)

clean-all: $(clean-targets)

.PHONY: $(known-targets) html html-finalize pdf pdf-finalize clean clean-all
