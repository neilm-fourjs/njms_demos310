
GBCBASE=$(PWD)

include makefile.inc

BASE=$(shell pwd)
dirs=gbc-njm gbc-teal gbc-elite gbc-gc

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
