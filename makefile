
export BIN=bin$(GENVER)

export PROJBASE=$(PWD)

export FGLIMAGEPATH=$(PROJBASE)/pics:$(FGLDIR)/lib/image2font.txt
export MUSICDIR=$(PROJBASE)/Music
export FGLRESOURCEPATH=$(PROJBASE)/etc
export FGLPROFILE=$(PROJBASE)/etc/sqt/profile:$(PROJBASE)/etc/profile.ur

export GBCPROJDIR=/opt/fourjs/gbc-current

export LANG=is_IS.utf8

all:
	gsmake njms_demos310.4pw

run: 
	cd $(BIN); fglrun menu.42r
