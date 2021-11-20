PROGRAMS = dmenu_emoji

.PHONY: all clean
all: $(PROGRAMS)

dmenu_emoji: dmenu_emoji.in Makefile
	m4 $< >$@
	chmod +x $@

clean:
	rm -f -- $(PROGRAMS)
