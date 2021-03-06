all: re

o:
	gcc -I $(CURDIR)/../../bin/include -ggdb -Wl,--start-group -Wall -Wextra -o rsa rsa_open.c -L $(CURDIR)/../../bin/lib  -lssl -lcrypto  -lpthread -ldl -Wl,--end-group


re:
	g++ reassemble.cpp -o reassemble.exe -g

run:
	reassemble.exe --off 0xf7580 libtest.so

download:
	wget http://www.mirrorservice.org/sites/dl.sourceforge.net/pub/sourceforge/g/gn/gns-3/Qemu%20Appliances/linux-tinycore-3.4.img

clean:
	rm -f reassemble.exe


find:
	@id=`ps -A | grep memcheck-amd64- | awk '{print $$1}'`; \
	print "Found $$id"; \
	if [ -z "$${id}" ]; then exit 1; fi; \
	python m.py $$id;
	-for f in `ls *.data`; do \
		if xxd -p $$f | tr -d '\n' | grep -c 'a4063e881916d40eec1b83ada255623f'; then\
			echo $$f; \
		fi; \
	done


di:
	cd distorm; make

vb:
	cd valgrind-gen; bash  autogen.sh; ./configure --prefix=$(HOME)/bin-valgrind

vc:
	cd valgrind-gen; make; make install

vr:
	$(HOME)/bin-valgrind/bin/valgrind --tool=tracegrind ls

ve:
	export FLYCHECK_GENERIC_SRC=$(CURDIR)/valgrind-gen; \
	export FLYCHECK_GENERIC_BUILD=$(CURDIR)/valgrind-gen; \
	emacs -nw valgrind-gen/tracegrind

ve_:
	export FLYCHECK_GENERIC_SRC=$(CURDIR)/valgrind-gen; \
	export FLYCHECK_GENERIC_BUILD=$(CURDIR)/valgrind-gen; \
	emacs valgrind-gen/tracegrind

tags:
	-cd valgrind-gen; rm GPATH GRTAGS GTAGS
	cd valgrind-gen; find include VEX/pub VEX coregrind lackey taintgrind  -type f | grep -e '.c$$\|.h$$' | gtags -i -f -

vg-taint-prep:
	cd valgrind-gen/taintgrind; ../autogen.sh; ./configure --prefix=$(HOME)/bin-valgrind; make clean

vg-taint:
	cd valgrind-gen/taintgrind; make; make install
