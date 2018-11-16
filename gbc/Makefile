
GBCBASE=$(PWD)

include makefile.inc

BASE=$(shell pwd)
dirs=gbc-clean gbc-njm gbc-teal gbc-gc

all: build/gbc-current subdirs

# Setup the GBC build env
build/gbc-current: 
	./gbc-setup.sh

subdirs: $(dirs)
	@for dir in $^ ; do  \
		cd $(BASE)/$$dir && make all; \
	done

clean:
	rm $(DISTBIN)/gbc*.zip
