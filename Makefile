FILTERS=$(wildcard filters/*)
.PHONY: test

test:
	@let err=0 ; \
	for d in $(FILTERS) ; do \
	    make -C $$d test ; \
	    if [ $$? -eq 0 ]; then \
	    	echo "PASS $$d" ; \
	    else \
	    	echo "FAIL $$d" ; \
		err=1 ; \
	    fi ; \
	done ; \
	exit $$err

