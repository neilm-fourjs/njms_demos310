
GBCBASE=$(PWD)

include makefile.inc

BASE=$(shell pwd)
dirs=gbc-njm gbc-elite gbc-teal gbc-gc gbc-hivis

all: build/gbc-$(GBCVER) subdirs

# Setup the GBC build env
build/gbc-$(GBCVER): 
	./gbc-setup.sh $(GBCVER) $(GBCBLD)

subdirs: $(dirs)
	@for dir in $^ ; do  \
		cd $(BASE)/$$dir && make all; \
	done

clean:
	rm $(DISTBIN)/gbc*.zip
