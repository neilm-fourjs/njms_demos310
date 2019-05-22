
export BIN=bin$(GENVER)

export PROJBASE=$(PWD)

export RENDERER=ur

export FGLGBCDIR=$(PROJBASE)/gbc/build/gbc-current/dist/customization/gbc-clean/
export FGLIMAGEPATH=$(PROJBASE)/pics:$(FGLDIR)/lib/image2font.txt
export MUSICDIR=$(PROJBASE)/Music
export FGLRESOURCEPATH=$(PROJBASE)/etc
export FGLPROFILE=$(PROJBASE)/etc/sqt/profile:$(PROJBASE)/etc/profile.$(RENDERER)
export WINDOWCENTER=FALSE
export GBCPROJDIR=/opt/fourjs/gbc-current

#export LANG=is_IS.utf8
export LANG=en_GB.utf8

all:
	gsmake njms_demos$(GENVER).4pw

clean:
	find . -name \*.42? -delete

run: 
	cd $(BIN); fglrun menu.42r
