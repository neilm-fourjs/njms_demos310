
export BASE=$(PWD)
export GGC=$(FGLDIR)/testing_utilities/ggc

export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export LD_LIBRARY_PATH=$(JAVA_HOME)/jre/lib/amd64/server
export CLASSPATH=$(GGC)/ggc.jar

export FGLRESOURCEPATH=../etc
export FGLIMAGEPATH=../pics
export FGLLDPATH=../bin:$(GGC)/lib

all: run

test1.log:
	cd ../bin && fglrun --start-guilog=$(PWD)/$@ ../bin/menu.42r	

test1.4gl: test1.log
	java com.fourjs.ggc.generator.GhostGenerator test1.log com.fourjs.ggc.generator.BDLProducer test1.4gl

test1.42m: test1.4gl
	fglcomp -I $(GGC)/lib $^

run: test1.42m
	cd ../bin && fglrun $(BASE)/test1.42m
