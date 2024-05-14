FUN_DIR = $${HOME}/.local/bin/functions

install:
	mkdir --parents $(FUN_DIR)
	cp ./*functions.sh $(FUN_DIR)
