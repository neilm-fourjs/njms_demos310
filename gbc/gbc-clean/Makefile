
GBCBASE=..

include ../makefile.inc

CUSTOMNAME=$(shell basename $(PWD))
THEME1=theme/colors/dark
THEME2=theme/colors/helper

TARGET=$(DISTBIN)/$(CUSTOMNAME)-$(PACKVER).zip

all: $(GBCBASE)/build/gbc-$(PACKVER)/$(THEME1) $(GBCBASE)/build/gbc-$(PACKVER)/$(THEME2) $(TARGET) 

# Create a symbolic link to our custom gbc files
$(GBCBASE)/build/gbc-$(PACKVER)/customization/$(CUSTOMNAME): 
	ln -s $(PWD) $@

# Create a symbolic link to our custom themes files
$(GBCBASE)/build/gbc-$(PACKVER)/$(THEME1):
	ln -s $(PWD)/$(THEME1) $@

$(GBCBASE)/build/gbc-$(PACKVER)/$(THEME2):
	ln -s $(PWD)/$(THEME2) $@

# Build our custom gbc
$(GBCBASE)/build/gbc-$(PACKVER)/dist/$(CUSTOMNAME): $(GBCBASE)/build/gbc-$(PACKVER) $(GBCBASE)/build/gbc-$(PACKVER)/customization/$(CUSTOMNAME)
	cd $(GBCBASE)/build/gbc-$(PACKVER) && grunt $(CFG) --customization=customization/$(CUSTOMNAME) 

# Package our custom gbc
$(TARGET): $(GBCBASE)/build/gbc-$(PACKVER)/dist/$(CUSTOMNAME)
	cd $(GBCBASE)/build/gbc-$(PACKVER)/dist/customization/$(CUSTOMNAME) && zip -r $@ * > $(CWD)/$(CUSTOMNAME).lst


dev:
	cd $(GBCBASE)/build/gbc-$(PACKVER) && grunt --customization=customization/$(CUSTOMNAME) dev

