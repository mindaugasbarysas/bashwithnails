# Bash With Nails
Bash With Nails (rhymes with ruby on rails) is a bash framework written for fun and profit. 

I'm kidding about the fun part.

It boasts of:

- loading of bash function collections in separate "modules".
- dependency management and automatic loading of relevant "modules".
- separate "modules" can have separate "namespaces", prefixing function names and non-global variables, e.g. `mymodule::myfunction`.
- if you want to refer to your own namespace, you can use `this::myfunction` in your module.
- named function parameters, e.g. `function myfunction(a b c) { echo "$a $b $c"; }`.
- weak OOP support, e.g. `oop::new oop_demo '1,2' 'obj_one'; oop::new oop_demo '3,4' 'obj_two'; oop::call 'obj_one' sum ""; oop::call 'obj_two' sum ""; oop::destroy 'obj_two' ''`

## How to run

`./app.sh`

and see the magic happen.

## Why "with nails"?

Because 

![cursed hammer](http://i.imgur.com/6qZcv6j.jpg?fb)

So it's only natural you want nails with that.
