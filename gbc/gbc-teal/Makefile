
GBCBASE=..

include ../makefile.inc

CUSTOMNAME=$(shell basename $(PWD))
THEME1=theme/colors/hivis

TARGET=$(DISTBIN)/$(CUSTOMNAME)-$(PACKVER).zip

all: $(GBCBASE)/build/gbc-$(PACKVER)/$(THEME1) $(GBCBASE)/build/gbc-$(PACKVER)/$(THEME2) $(GBCBASE)/build/gbc-$(PACKVER)/$(THEME3) $(TARGET)

# Create a symbolic link to our custom gbc files
$(GBCBASE)/build/gbc-$(PACKVER)/customization/$(CUSTOMNAME): 
	ln -s $(PWD) $@

# Create a symbolic link to our custom themes files
$(GBCBASE)/build/gbc-$(PACKVER)/$(THEME1): $(PWD)/$(THEME1)/theme.scss.json
	ln -s $(PWD)/$(THEME1) $@

# Build our custom gbc
$(GBCBASE)/build/gbc-$(PACKVER)/dist/$(CUSTOMNAME): $(GBCBASE)/build/gbc-$(PACKVER) $(GBCBASE)/build/gbc-$(PACKVER)/customization/$(CUSTOMNAME)
	cd $^ && grunt $(CFG) --customization=customization/$(CUSTOMNAME) | tee $(PWD)/$(CUSTOMNAME).build

# Package our custom gbc
$(TARGET): $(GBCBASE)/build/gbc-$(PACKVER)/dist/$(CUSTOMNAME)
	cd $(GBCBASE)/build/gbc-$(PACKVER)/dist/customization/$(CUSTOMNAME) && zip -r $@ *


dev:
	cd $(GBCBASE)/build/gbc-$(PACKVER) && grunt --customization=customization/$(CUSTOMNAME) dev

