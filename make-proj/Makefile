sources = foo.c bar.c
objects = $(sources:.c=.o)
program = foo

all: $(program)

$(program): $(objects)
	$(CC) $^ -o $@

%.d: %.c
	@set -e; rm -f $@; \
	$(CC) -MM $(CPPFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$

-include $(sources:.c=.d)

.PHONY: clean

clean:
	rm *.o *.d $(program)
