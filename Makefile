all: obj obj/un.o obj/decompressors.o
	csc obj/un.o obj/decompressors.o -o un

clean:
	rm -f obj/*
	rm -f un

obj:
	mkdir obj

obj/un.o: un.scm
	csc -c un.scm -o obj/un.o

obj/decompressors.o: decompressor.scm obj/decompressors.scm
	csc -c obj/decompressors.scm -o obj/decompressors.o

obj/decompressors.scm: $(wildcard decompressor/*scm)
	echo "(declare (unit decompressors))" > obj/decompressors.scm
	cat decompressor.scm >> obj/decompressors.scm
	cat decompressor/*scm >> obj/decompressors.scm
