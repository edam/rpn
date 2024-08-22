Reverse Polish Notation Calculator
====================

Simple calculator/interpreter.

Running
-------

For a REPL:

`$ rpn`

or run scripts:

`$ rpn script1 script2`

Or run commands:

`$ rpn -c 4 5 +`

Unless there is an error, or the commands quit (with `q`), any remaining stack
is dumped on exit.

Building
--------

Rpn is writen in [V](http://vlang.io).  You will need to install V first.  Then
install rpn's dependencies, then run `v .` to build.

Something like this:

``` Shell
git clone https://github.com/vlang/v
cd v
make
cd ..
git clone https://github.com/edam/rpn
cd rpn
../v/v install edam.ggetopt edam.greadline prantlf.pcre2
../v/v .
```
