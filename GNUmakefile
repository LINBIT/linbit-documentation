all:
ifndef MAKEDOC
	$(error Please set the MAKEDOC variable pointing to your makedoc checkout)
endif
	ln -s $(MAKEDOC)/Makefile.am
	ln -s $(MAKEDOC)/configure.ac.stub
	ln -s $(MAKEDOC)/autogen.sh
	$(info Now run ./autogen.sh)
