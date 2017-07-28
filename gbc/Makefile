
export GBCPROJECTDIR=$(HOME)/FourJs_Downloads/GBC

GBCVER=1.00.37
GBCBLD=201706291754
CUSTOMNAME1=gbc-njm
CUSTOMNAME2=gbc-teal
CUSTOMNAME3=gbc-elite
DISTBIN=../distbin

all: $(DISTBIN)/$(CUSTOMNAME1)-$(GBCVER).zip $(DISTBIN)/$(CUSTOMNAME2)-$(GBCVER).zip $(DISTBIN)/$(CUSTOMNAME3)-$(GBCVER).zip

# Setup the GBC build env
build/gbc-$(GBCVER): $(GBCPROJECT)
	./gbc-setup.sh $(GBCVER) $(GBCBLD)

# 1 Create a symbolic link to our custom gbc files
build/gbc-$(GBCVER)/customization/$(CUSTOMNAME1): 
	ln -s ../../../$(CUSTOMNAME1) $@

# 2 Create a symbolic link to our custom gbc files
build/gbc-$(GBCVER)/customization/$(CUSTOMNAME2): 
	ln -s ../../../$(CUSTOMNAME2) $@

# 3 Create a symbolic link to our custom gbc files
build/gbc-$(GBCVER)/customization/$(CUSTOMNAME3): 
	ln -s ../../../$(CUSTOMNAME3) $@

# 1 Build our custom gbc
build/gbc-$(GBCVER)/dist/$(CUSTOMNAME1): build/gbc-$(GBCVER) build/gbc-$(GBCVER)/customization/$(CUSTOMNAME1)
	cd $^ && grunt --customization=customization/$(CUSTOMNAME1)

# 2 Build our custom gbc
build/gbc-$(GBCVER)/dist/$(CUSTOMNAME2): build/gbc-$(GBCVER) build/gbc-$(GBCVER)/customization/$(CUSTOMNAME2)
	cd $^ && grunt --customization=customization/$(CUSTOMNAME2)

# 3 Build our custom gbc
build/gbc-$(GBCVER)/dist/$(CUSTOMNAME3): build/gbc-$(GBCVER) build/gbc-$(GBCVER)/customization/$(CUSTOMNAME3)
	cd $^ && grunt --customization=customization/$(CUSTOMNAME3)

# 1 Package our custom gbc
$(DISTBIN)/$(CUSTOMNAME1)-$(GBCVER).zip: build/gbc-$(GBCVER)/dist/$(CUSTOMNAME1)
	cd build/gbc-$(GBCVER)/dist/customization/$(CUSTOMNAME1) && zip -r ../../../../../$(DISTBIN)/$@ *

# 2 Package our custom gbc
$(DISTBIN)/$(CUSTOMNAME2)-$(GBCVER).zip: build/gbc-$(GBCVER)/dist/$(CUSTOMNAME2)
	cd build/gbc-$(GBCVER)/dist/customization/$(CUSTOMNAME2) && zip -r ../../../../../$(DISTBIN)/$@ *

# 3 Package our custom gbc
$(DISTBIN)/$(CUSTOMNAME3)-$(GBCVER).zip: build/gbc-$(GBCVER)/dist/$(CUSTOMNAME3)
	cd build/gbc-$(GBCVER)/dist/customization/$(CUSTOMNAME3) && zip -r ../../../../../$(DISTBIN)/$@ *

