FUN_DIR = /opt/functions

install:
	mkdir --parents $(FUN_DIR)
	cp ./*functions.sh $(FUN_DIR)
