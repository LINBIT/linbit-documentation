languages = en ja
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
known-targets += $(foreach l,$(languages),$(addprefix $(l)/,clean))
# pot targets
known-targets += en/pot

$(known-targets):
	make -C $(@D) $(@F)

.PHONY: $(known-targets) html html-finalize pdf pdf-finalize clean
