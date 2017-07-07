
export GBCPROJECTDIR=$(HOME)/FourJs_Downloads/GBC

GBCVER=1.00.37
GBCBLD=201706291754
CUSTOMNAME=gbc-njm
DISTBIN=../distbin

all: $(DISTBIN)/$(CUSTOMNAME)-$(GBCVER).zip

# Setup the GBC build env
build/gbc-$(GBCVER): $(GBCPROJECT)
	./gbc-setup.sh $(GBCVER) $(GBCBLD)

# Create a symbolic link to our custom gbc files
build/gbc-$(GBCVER)/customization/$(CUSTOMNAME): 
	ln -s $(PWD)/$(CUSTOMNAME) $@

# Build our custom gbc
build/gbc-$(GBCVER)/dist/$(CUSTOMNAME): build/gbc-$(GBCVER) build/gbc-$(GBCVER)/customization/$(CUSTOMNAME)
	cd $^ && grunt --customization=customization/$(CUSTOMNAME)

# Package our custom gbc
$(DISTBIN)/$(CUSTOMNAME)-$(GBCVER).zip: build/gbc-$(GBCVER)/dist/$(CUSTOMNAME)
	cd build/gbc-$(GBCVER)/dist/customization/$(CUSTOMNAME) && zip -r ../../../../../$(DISTBIN)/$@ *

