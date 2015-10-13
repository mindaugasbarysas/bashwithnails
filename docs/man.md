# Documentation

## Requirements

- *nix running bash (3.2 looks good) or whatever with slashes pointing the right side up (/)
- wget (yeah, yeah, I should use curl...)

## Usage

Usage of this framework is very simple:

```
#!/bin/bash

DIR=`dirname "${BASH_SOURCE[0]}"`
if [[ -f $DIR/bootstrap.sh ]]
then
    . $DIR/bootstrap.sh
else
    echo "bootstrap not found"
    exit 256
fi

bootstrap_load_module demo/app

# run.
demo::run 'HELLO, WORLD'
```

Let's see what's happening here: first we find out where we are, then we load bootstrap. When bootstrap is ready, we load our module `demo/app` (which has namespace `demo`) with `bootstrap_load_module demo/app` and call our modules' `run` function with parameter `'HELLO, WORLD'`. Easy as 1, 2, 3!

## Features

- Automatic loading of required modules. Just say `dependencies::depends "foo/bar"` in your module, and it will be automatically loaded. If `foo/bar` requires `something/else`, it will be also loaded.
- Ever wanted to have named parameters in bash functions? Now you can! Just write:`function a(b c) { echo $b $c; }` and cry tears of joy!
- *My functions share the same name as some other modules' functions!* - I hear ~~myself~~ you cry. Despair no more - write `#NAMESPACE=my::awesome::namespace` after the shebang and your functions will be prepended by `my::awesome::namespace`. To call them internally you can use `this::` also. If you want your variables to be namespaced as well, just write `namespaced MYVAR='...'` and `${namespaced MYVAR}`.
- Ever wanted to do lame OOP programming in bash? Now you can with `core/oop` module!
- Some testing functionality.
- There's always something more ~~nobody needs and I can challenge myself doing~~!

## Config

All global vars are stored in `vars/environment.sh`. There are currently 7 of them by default:

- `DIR` - Current script location,
- `SCRIPT_DIR` - because having one script location is simply not enough,
- `GLOBAL_REPOSITORY_ADDRESS` - that's where the (default) repository is defined,
- `GLOBAL_CACHE_DIR` - where we keep our repository cache.
- `ERROR_NOT_FOUND` - error constant when something's not found. That's it.
- `ERROR_BAD_PROGRAMMER` - developer screwed up. Not used yet.
- `ERROR_BAD_USER` - user has asked something that is simply not acceptable.

## Core Modules

There currently are three modules designed to make your life ~~miserable~~ easy:
- `core/dependencies`
- `core/packager`
- `core/oop`
- `core/testing/tests`

### core/dependencies

core/dependencies deals with dependencies. Ironically, it depends on core/packager to download any missing modules from repositories defined in `vars/environment.sh`.

#### Namespace
dependencies

#### Functions
`dependencies::depends($module)` - assures that $module is loaded or dies honorably having exhausted all means of loading said module.

`dependencies::register_module($module)` - notes that $module is loaded, but $module should ask for it itself by calling this function. If $module does not do that, it will get loaded again and again. It is possible for $some_other_module to say "hey, i'm $module, register me ::dependencies!", and dependencies will do that. It's not its' job to judge and assign roles.

### core/packager

core/packager deals with modules that are not there. It tries to get them from the ~~intertubes~~ ~~interwebs~~ ~~internets~~ web by using wget.

#### Namespace
packager

#### Functions

`packager::set_repository($repository_name)` - When you don't want to use the default -`GLOBAL_REPOSITORY_ADDRESS`, you can set your own $repository_name.

`packager::set_cache_dir($cache_dir)` - same, but with cache directory.

`packager::get_module($module_name)` - download module and put it where it belongs.

`packager::cleanup` - does nothing yet.

### core/oop

Provides "object" support. Of sorts. Because somebody asked me if that's possible.

#### Namespace
oop

#### Functions
`new($namespace $constructor_args $object_name)` - creates new "object" of $namespace type, calls its' constructor (`__construct`) with $constructor_args separated with `,`, assigns it an $object_name;

`call($object $function_name $args)` - calls a "method" ($function_name) of an "object" with name $object with arguments ($args) separated with `,`

`destroy($object $args)` - equivalent to `call $object '__destruct' $args`. $args is once again, separated with `,`

**NB** (and raise an issue to myself): you better not be passing any args with ',' in them now! (will remove **NB** when it is no longer necessary) **NB**

### core/testing/tests

Provides testing support. Can automatically run tests for a namespace. Unit tests are nice. Maybe I'll cover bashwithnails with unit tests someday.

#### Namespace
testing

#### Functions
`assert($expected $actual)` - checks if `$expected` equals `$actual`. Logs traces and failed expectations sulkingly.

`run_tests($namespace)` - loads tests for `$namespace` if they exist. Complains if they don't. 
Prints out failures and statistics (Tests run, assertions, failures). 
Looks for tests in modules/tests directory.
Tests' namespace should be prefixed with `tests::`, 
i.e. if the tests cover namespace `my_awesome_namespace`, test module should be located in `modules/tests/my_awesome_namespace`
and should have a namespace `tests::my_awesome_namespace`.

** For more information about testing see modules/tests/core/ directory and ./tests.sh  **
(also, 
[![Build Status](https://travis-ci.org/mindaugasbarysas/bashwithnails.svg?branch=master)](https://travis-ci.org/mindaugasbarysas/bashwithnails))
## Internals

### bootstrap.sh

`bootstrap.sh` provides the absolute core of the Nails. It loads the environment and provides functions to load and mangle modules to our liking. It also loads `core/dependencies` by default.

#### Namespace
**GLOBAL**

#### Functions
`bootstrap_load_environment` - loads environment.

`bootstrap_load_module($module)` - loads $module, sets its' namespace and does other black magick (e.g. makes functions accept their named parameters),

`bootstrap_module_from_namespace($namespace)` - lookup function used to find modules providing $namespace

`bootstrap_load_namespace($namespace)` - loads modules providing $namespace

`bootstrap_trace` - prints out a stack trace
