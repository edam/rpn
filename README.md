Reverse Polish Notation Calculator
====================

Simple RPN calculator/interpreter.

Running
-------

A REPL:

```
$ rpn
rpn> 5 4 +
11
```

Or scripts:

```
$ echo 5 4 + > foo
$ rpn foo
11
```

Or run commands directly:

```
$ rpn -c 4 5 +
11
```

Unless there is an error, or the quit command (`q`) is issued, the remaining
stack is dumped on exit.  This can be suppressed with `-q`.

Building
--------

Rpn is writen in [V](http://vlang.io).  You will need to install V first.

```
git clone https://github.com/vlang/v
cd v
make
```

Note: You will need to add the V binary to the `PATH` manually.

Then build rpn...

``` Shell
git clone https://github.com/edam/rpn
cd rpn
v install edam.ggetopt edam.greadline prantlf.pcre2
v .
```

Commands
--------

Rpn currently knows the following commands:

Commands:
  d  dump stack
  p  pop and print top of stack ("P" displays raw values)
  t  print type of top of stack
  +  add last two stack values, push result to stack
  -  subtract last stack values from the one before, push result to stack
  *  multiply last two stack values, push result to stack
  /  divide last stack value by the one before, push result to stack
  !  negate value at top of stack (0=false)
  .  duplicate top of stack
  _  pop and discard top of stack
  e  pop and execute top of stack
  x  clear stack
  q  quit

All other values encountered are pushed to stack a value.  Rpn supports the
following types:
 * integer
 * float
 * string
 * nil

In the REPL (only) you can also run the following commands:
  h  show help
  i  toggle debug info
