
GBCBASE=$(PWD)

include makefile.inc

BASE=$(shell pwd)
dirs=gbc-njm gbc-elite gbc-teal gbc-gc gbc-hivis

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
