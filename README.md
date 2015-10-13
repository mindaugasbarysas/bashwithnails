# Bash With Nails
Bash With Nails (rhymes with ruby on rails) is a bash framework written for fun and profit. 

I'm kidding about the fun and profit part.

It has:

- loading of bash function collections in separate "modules".
- dependency management and automatic loading of relevant "modules".
- separate "modules" can have separate "namespaces", prefixing function names and non-global variables, e.g. `mymodule::myfunction`.
- if you want to refer to your own namespace, you can use `this::myfunction` in your module.
- named function parameters, e.g. `function myfunction(a b c) { echo "$a $b $c"; }`.
- weak OOP support, e.g. `oop::new oop_demo '1,2' 'obj_one'; oop::new oop_demo '3,4' 'obj_two'; oop::call 'obj_one' sum ""; oop::call 'obj_two' sum ""; oop::destroy 'obj_two' ''`
- modules can be downloaded from the repository (as seen in sample_repo folder)
- tests of unit kind, kind of :) (yes, it works with travis)

see [Docs](https://github.com/mindaugasbarysas/bashwithnails/blob/master/docs/man.md) or clone and run for more information.

[![Build Status](https://travis-ci.org/mindaugasbarysas/bashwithnails.svg?branch=master)](https://travis-ci.org/mindaugasbarysas/bashwithnails)

## How to run

`./app.sh`

and see all the magic described above happen.

## Why "with nails"?

Because 

![cursed hammer](http://i.imgur.com/6qZcv6j.jpg?fb)

So it's only natural you want nails with that. Or you can keep on bashing your thumbs - it's a free world!
