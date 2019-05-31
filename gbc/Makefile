
BASE=$(PWD)
dirs=gbc_clean gbc_njm gbc_teal gbc_gc gbc_mdi

all: subdirs

subdirs: $(dirs)
	@for dir in $^ ; do  \
		cd $(BASE)/$$dir && make; \
	done

clean:
	find . -name \*.zip -delete
