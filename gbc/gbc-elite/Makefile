
GBCBASE=..

include ../makefile.inc

CUSTOMNAME=$(shell basename $(PWD))

all: ../../../../../$(DISTBIN)/$(CUSTOMNAME)-$(PACKVER).zip

# Create a symbolic link to our custom gbc files
$(GBCBASE)/build/gbc-$(PACKVER)/customization/$(CUSTOMNAME): 
	ln -s ../../../$(CUSTOMNAME) $@

# Build our custom gbc
$(GBCBASE)/build/gbc-$(PACKVER)/dist/$(CUSTOMNAME): $(GBCBASE)/build/gbc-$(PACKVER) $(GBCBASE)/build/gbc-$(PACKVER)/customization/$(CUSTOMNAME)
	cd $^ && grunt --customization=customization/$(CUSTOMNAME) | tee $(PWD)/$(CUSTOMNAME).build

# Package our custom gbc
../../../../../$(DISTBIN)/$(CUSTOMNAME)-$(PACKVER).zip: $(GBCBASE)/build/gbc-$(PACKVER)/dist/$(CUSTOMNAME)
	cd $(GBCBASE)/build/gbc-$(PACKVER)/dist/customization/$(CUSTOMNAME) && zip -r $@ *


dev:
	cd $(GBCBASE)/build/gbc-$(PACKVER) && grunt --customization=customization/$(CUSTOMNAME) dev

