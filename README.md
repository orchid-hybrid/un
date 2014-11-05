un
==

The `un` tool is a universal uncompressor. The idea is that you invoke it like this:

   un myarchive.whatever

and it will work out which decompression tool to use and create an invocation line for it.

* It will be careful not to let lots of files splay out in your current directory, putting them into a their own directory (unless the archive contains a single file or directory itself).

* It tests the processes exit code to determine whether extraction failed or not.
