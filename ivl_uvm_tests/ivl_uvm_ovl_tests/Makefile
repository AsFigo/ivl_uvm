SUBDIRS = $(shell ls -d */)
all:
	for dir in $(SUBDIRS) ; do \
        	make --no-print-directory -C  $$dir ; \
	done

clean:
	for dir in $(SUBDIRS) ; do \
        	make --no-print-directory -C  $$dir clean;\
	done

help:
	for dir in $(SUBDIRS) ; do \
        	make --no-print-directory -C  $$dir help;\
	done
   
   