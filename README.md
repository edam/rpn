Reverse Polish Notation Interpreter
====================

Simple command-line RPN calculator and interpreter, featuring:

* A stack and commands to manipulate it
* Memory storage and named variables
* A REPL + command history file
* Automatic type inference and promotion
* Fancy error reporting

Rpn was written for fun.

Usage
-----

Rpn currently has the following commands:

Commands:
* `+`: add last two stack values, push result to stack
* `-`: subtract last stack values from the one before, push result to stack
* `*`: multiply last two stack values, push result to stack
* `/`: divide last stack value by the one before, push result to stack
* `!`: negate value at top of stack (0=false)
* `>`: pop and store (to a named variable with ">VAR")
* `<`: fetch and push (from a named variable with "<VAR")
* `.`: duplicate top of stack
* `s`: swap the top two items on the stack
* `_`: pop and discard top of stack
* `e`: pop and execute top of stack
* `d`: dump stack
* `p`: pop and print top of stack ("P" displays raw values)
* `t`: print type of top of stack
* `x`: clear stack
* `q`: quit

All other values encountered are push a value to the stack.  Rpn supports the
following types:
* integer
* float
* string
* nil

In the REPL (only) you can also run the following commands:
* `h`: show help
* `i`: toggle debug info

Running
-------

A REPL:

```
$ rpn
rpn> 5 4 +
11
```

Scripting:

```
$ echo 5 4 + > foo
$ rpn foo
11
```

Running commands directly:

```
$ rpn -c 4 5 +
11
```

Note: the remaining stack is dumped on exit, unless:
* there is an error
* a quit command (`q`) is issued
* it is suppressed (`--quiet`)

Building
--------

Rpn is writen in [V](http://vlang.io).  You will need to install V first.

```
git clone https://github.com/vlang/v
cd v
make
./v symlink
```

Then build rpn...

``` Shell
git clone https://github.com/edam/rpn
cd rpn
v install
v .
```
