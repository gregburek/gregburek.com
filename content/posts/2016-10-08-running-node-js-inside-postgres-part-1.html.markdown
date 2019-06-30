---
title: Running Node.js inside Postgres, Part 1
date: "2016-10-08"
tags: [ node, npm, postgres, nodejs, discovery, plv8, plv8x ]
---

[PLV8](https://github.com/plv8/plv8) is a procedural language for Postgres,
that runs JavaScript, powered by the
[V8](https://en.wikipedia.org/wiki/V8_(JavaScript_engine)) runtime. This allows
generic JavaScript code to be executed on a Postgres host, with the same
runtime that the web browser Chrome uses. So, it follows that most code that
could run in a browser should also be able to be run in Postgres.

PLV8 has been an extension of Postgres since version 9.2, and has been
available on [Heroku
Postgres](https://devcenter.heroku.com/articles/heroku-postgres-extensions-postgis-full-text-search#languages)
professional tier databases for about as long.

# This is probably a bad idea


While potentially powerful, I personally have not seen much use of PLV8 other
than causing Out of Memory errors on busy Postgres dbs.

This series of posts aims to document my attempts to use node modules and npm
in PLV8 to develop a simple js app that uses Postgres as a runtime for the V8
runtime.

To be fair, this is one of my first attempts at using node and npm, so these
posts will be about that as much as anything.

# Why?

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Why use node when you can use Postgres as your JavaScript runtime?</p>&mdash; Damaged Guids (@t_crayford) <a href="https://twitter.com/t_crayford/status/784529763603976192">October 7, 2016</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Why not?

![Why not Postgres?](https://i.imgur.com/S0YQYR4.jpg)

# Goal

To have a Postgres function that logs into twitter and downloads my home feed to
the database it runs in. I'll limit myself to a Heroku Postgres db, out of my
own convenience. I'll attempt to use
[twitter-node-client](https://github.com/BoyCook/TwitterJSClient) for this
purpose.

EDIT: [This goal is not currently possible.](/2017/09/01/running-node-js-inside-postgres-part-mea-culpa/)

# First thing to attempt

A google search for `node plv8` led me to the
[plv8x project](https://github.com/clkao/plv8x), which provides a cli and
allows importing of npm modules into the db. I'll start here.

## Install node

I downloaded and installed the [official node
packages](https://nodejs.org/en/download/) for my system.

## Create a Heroku app and Postgres DB

```
gburek@gburek-ltm2:~/code
> mkdir pg-twitter

gburek@gburek-ltm2:~/code
> cd pg-twitter

gburek@gburek-ltm2:~/code/pg-twitter
> git init
Initialized empty Git repository in /Users/gburek/code/pg-twitter/.git/

gburek@gburek-ltm2:~/code/pg-twitter
> heroku create pg-twitter
Creating ⬢ pg-twitter... done
https://pg-twitter.herokuapp.com/ | https://git.heroku.com/pg-twitter.git

gburek@gburek-ltm2:~/code/pg-twitter
> heroku addons:create heroku-postgresql:standard-0
Creating heroku-postgresql:standard-0 on ⬢ pg-twitter... $50/month
Created postgresql-triangular-47265 as DATABASE_URL
The database should be available in 3-5 minutes.
     ! The database will be empty. If upgrading, you can transfer
     ! data from another database with pg:copy.
Use `heroku pg:wait` to track status
Use heroku addons:docs heroku-postgresql to view documentation
```

After a few minutes, our new db is available and has plv8 available for use:

```
gburek@gburek-ltm2:~/code/pg-twitter
> heroku pg:wait
Waiting for database postgresql-triangular-47265... available

gburek@gburek-ltm2:~/code/pg-twitter
> heroku pg:psql
---> Connecting to DATABASE_URL
Timing is on.
Expanded display is used automatically.
psql (9.5.3, server 9.5.4)
SSL connection (protocol: TLSv1.2, cipher: ECDHE-RSA-AES256-GCM-SHA384, bits: 256, compression: off)
Type "help" for help.

=> CREATE EXTENSION plv8;
CREATE EXTENSION
Time: 1109.898 ms
```

Now, on to working with plv8x.

## plv8x

First, I'm going to create a new npm project:

```
gburek@gburek-ltm2:~/code/pg-twitter
> npm init --yes
Wrote to /Users/gburek/code/pg-twitter/package.json:

{
  "name": "pg-twitter",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "keywords": [],
  "author": "",
  "license": "ISC"
}
```

Now, to install plv8x. Surely, `npm install plv8x --save` will work.

<details>
<summary>Click here to see 400+ lines of woe, errors and false starts. </summary>

```
gburek@gburek-ltm2:~/code/pg-twitter
> npm install plv8x --save
npm WARN prefer global LiveScript@1.2.0 should be installed with -g

> libpq@1.8.5 install /Users/gburek/code/pg-twitter/node_modules/libpq
> node-gyp rebuild

gyp WARN download NVM_NODEJS_ORG_MIRROR is deprecated and will be removed in node-gyp v4, please use NODEJS_ORG_MIRROR
gyp WARN download NVM_NODEJS_ORG_MIRROR is deprecated and will be removed in node-gyp v4, please use NODEJS_ORG_MIRROR
gyp WARN download NVM_NODEJS_ORG_MIRROR is deprecated and will be removed in node-gyp v4, please use NODEJS_ORG_MIRROR
  CXX(target) Release/obj.target/addon/src/connection.o
  CXX(target) Release/obj.target/addon/src/connect-async-worker.o
  CXX(target) Release/obj.target/addon/src/addon.o
  SOLINK_MODULE(target) Release/addon.node
clang: warning: libstdc++ is deprecated; move to libc++ with a minimum deployment target of OS X 10.9
pg-twitter@1.0.0 /Users/gburek/code/pg-twitter
└─┬ plv8x@0.6.6
  ├── async@0.9.2
  ├─┬ js-yaml@3.0.2
  │ ├─┬ argparse@0.1.16
  │ │ ├── underscore@1.7.0
  │ │ └── underscore.string@2.4.0
  │ └── esprima@1.0.4
  ├─┬ LiveScript@1.2.0
  │ └── prelude-ls@1.0.3
  ├─┬ one@2.5.2
  │ ├── boxcars@2.0.0
  │ ├─┬ debug@2.2.0
  │ │ └── ms@0.7.1
  │ ├── flatten-array@1.0.0
  │ ├── functools@1.4.0
  │ ├─┬ glob@7.1.1
  │ │ ├── fs.realpath@1.0.0
  │ │ ├─┬ inflight@1.0.5
  │ │ │ └── wrappy@1.0.2
  │ │ ├── inherits@2.0.3
  │ │ ├─┬ minimatch@3.0.3
  │ │ │ └─┬ brace-expansion@1.1.6
  │ │ │   ├── balanced-match@0.4.2
  │ │ │   └── concat-map@0.0.1
  │ │ ├── once@1.4.0
  │ │ └── path-is-absolute@1.0.1
  │ └── hogan.js@2.0.0
  ├─┬ optimist@0.6.1
  │ ├── minimist@0.0.10
  │ └── wordwrap@0.0.3
  ├─┬ pg@4.5.6
  │ ├── buffer-writer@1.0.1
  │ ├── generic-pool@2.4.2
  │ ├── packet-reader@0.2.0
  │ ├── pg-connection-string@0.1.3
  │ ├─┬ pg-types@1.11.0
  │ │ ├── ap@0.2.0
  │ │ ├── postgres-array@1.0.0
  │ │ ├── postgres-bytea@1.0.0
  │ │ ├── postgres-date@1.0.3
  │ │ └─┬ postgres-interval@1.0.2
  │ │   └── xtend@4.0.1
  │ ├─┬ pgpass@0.0.3
  │ │ └─┬ split@0.3.3
  │ │   └── through@2.3.8
  │ └── semver@4.3.6
  ├─┬ pg-native@1.10.0
  │ ├─┬ libpq@1.8.5
  │ │ ├── bindings@1.2.1
  │ │ └── nan@2.4.0
  │ ├── pg-types@1.6.0
  │ └─┬ readable-stream@1.0.31
  │   ├── core-util-is@1.0.2
  │   ├── isarray@0.0.1
  │   └── string_decoder@0.10.31
  ├── resolve@0.6.3
  └─┬ tmp@0.0.29
    └── os-tmpdir@1.0.2

npm WARN pg-twitter@1.0.0 No description
npm WARN pg-twitter@1.0.0 No repository field.
```

ok, now to try and run it against my new db:

```
gburek@gburek-ltm2:~/code/pg-twitter
> export PLV8XDB=$(h config:get DATABASE_URL)

gburek@gburek-ltm2:~/code/pg-twitter
> find . -name plv8x
./node_modules/.bin/plv8x
./node_modules/plv8x

gburek@gburek-ltm2:~/code/pg-twitter
> ./node_modules/.bin/plv8x -l
module.js:457
    throw err;
    ^

Error: Cannot find module 'boxcars'
    at Function.Module._resolveFilename (module.js:455:15)
    at Function.Module._load (module.js:403:25)
    at Module.require (module.js:483:17)
    at require (internal/module.js:20:19)
    at Object.<anonymous> (/Users/gburek/code/pg-twitter/node_modules/one/lib/templating/coll.js:1:77)
    at Module._compile (module.js:556:32)
    at Object.Module._extensions..js (module.js:565:10)
    at Module.load (module.js:473:32)
    at tryModuleLoad (module.js:432:12)
    at Function.Module._load (module.js:424:3)

```

welp, this sucks. Maybe I have to install it globally? The README seems to
suggest that.

```
gburek@gburek-ltm2:~/code/pg-twitter
> npm install plv8x -g
/Users/gburek/.nvm/versions/node/v6.7.0/bin/plv8x -> /Users/gburek/.nvm/versions/node/v6.7.0/lib/node_modules/plv8x/bin/cmd.js
...

gburek@gburek-ltm2:~/code/pg-twitter
> plv8x -l
>
module.js:457
    throw err;
    ^

Error: Cannot find module 'boxcars'
    at Function.Module._resolveFilename (module.js:455:15)
    at Function.Module._load (module.js:403:25)
    at Module.require (module.js:483:17)
    at require (internal/module.js:20:19)
    at Object.<anonymous>
(/Users/gburek/.nvm/versions/node/v6.7.0/lib/node_modules/plv8x/node_modules/one/lib/templating/coll.js:1:77)
    at Module._compile (module.js:556:32)
    at Object.Module._extensions..js (module.js:565:10)
    at Module.load (module.js:473:32)
    at tryModuleLoad (module.js:432:12)
    at Function.Module._load (module.js:424:3)
```

Uh ok. Maybe I need to install from github?

```
gburek@gburek-ltm2:~/code/pg-twitter
> npm uninstall plv8x -g
...

gburek@gburek-ltm2:~/code/pg-twitter
> npm install https://github.com/clkao/plv8x --save
npm WARN deprecated minimatch@2.0.10: Please update to minimatch 3.0.2 or higher to avoid a RegExp DoS issue
- boxcars@2.0.0 node_modules/boxcars
- flatten-array@1.0.0 node_modules/flatten-array
- fs.realpath@1.0.0 node_modules/fs.realpath
- functools@1.4.0 node_modules/functools
- hogan.js@2.0.0 node_modules/hogan.js
- ms@0.7.1 node_modules/ms
- debug@2.2.0 node_modules/debug
- one@2.5.2 node_modules/one
- path-is-absolute@1.0.1 node_modules/path-is-absolute
pg-twitter@1.0.0 /Users/gburek/code/pg-twitter
└─┬ plv8x@0.7.0  (git+https://github.com/clkao/plv8x.git#3c19d57adfa5050c27715699d2369d2c441c817d)
...

npm WARN pg-twitter@1.0.0 No description
npm WARN pg-twitter@1.0.0 No repository field.
npm install https://github.com/clkao/plv8x --save  10.96s user 2.93s system 85% cpu 16.253 total

gburek@gburek-ltm2:~/code/pg-twitter
> find . -name plv8x
./node_modules/.bin/plv8x
./node_modules/plv8x
./node_modules/plv8x/bin/plv8x

gburek@gburek-ltm2:~/code/pg-twitter
> ./node_modules/plv8x/bin/plv8x -l
module.js:457
    throw err;
    ^

Error: Cannot find module '../lib/cli.js'
    at Function.Module._resolveFilename (module.js:455:15)
    at Function.Module._load (module.js:403:25)
    at Module.require (module.js:483:17)
    at require (internal/module.js:20:19)
    at Object.<anonymous> (/Users/gburek/code/pg-twitter/node_modules/plv8x/bin/plv8x:2:1)
    at Module._compile (module.js:556:32)
    at Object.Module._extensions..js (module.js:565:10)
    at Module.load (module.js:473:32)
    at tryModuleLoad (module.js:432:12)
    at Function.Module._load (module.js:424:3)
```

Ok. Different error. Progress! Try again, globally, from github.

```
gburek@gburek-ltm2:~/code/pg-twitter
> npm install https://github.com/clkao/plv8x -g
npm WARN deprecated minimatch@2.0.10: Please update to minimatch 3.0.2 or higher to avoid a RegExp DoS issue
/Users/gburek/.nvm/versions/node/v6.7.0/bin/plv8x -> /Users/gburek/.nvm/versions/node/v6.7.0/lib/node_modules/plv8x/bin/plv8x

> libpq@1.8.5 install /Users/gburek/.nvm/versions/node/v6.7.0/lib/node_modules/plv8x/node_modules/libpq
> node-gyp rebuild

gyp WARN download NVM_NODEJS_ORG_MIRROR is deprecated and will be removed in node-gyp v4, please use NODEJS_ORG_MIRROR
gyp WARN download NVM_NODEJS_ORG_MIRROR is deprecated and will be removed in node-gyp v4, please use NODEJS_ORG_MIRROR
gyp WARN download NVM_NODEJS_ORG_MIRROR is deprecated and will be removed in node-gyp v4, please use NODEJS_ORG_MIRROR
  CXX(target) Release/obj.target/addon/src/connection.o
  CXX(target) Release/obj.target/addon/src/connect-async-worker.o
  CXX(target) Release/obj.target/addon/src/addon.o
  SOLINK_MODULE(target) Release/addon.node
clang: warning: libstdc++ is deprecated; move to libc++ with a minimum deployment target of OS X 10.9
/Users/gburek/.nvm/versions/node/v6.7.0/lib
└─┬ plv8x@0.7.0  (git+https://github.com/clkao/plv8x.git#3c19d57adfa5050c27715699d2369d2c441c817d)
...

npm install https://github.com/clkao/plv8x -g  13.35s user 5.16s system 90% cpu 20.531 total

gburek@gburek-ltm2:~/code/pg-twitter
> plv8x -l
module.js:457
    throw err;
    ^

Error: Cannot find module '../lib/cli.js'
    at Function.Module._resolveFilename (module.js:455:15)
    at Function.Module._load (module.js:403:25)
    at Module.require (module.js:483:17)
    at require (internal/module.js:20:19)
    at Object.<anonymous> (/Users/gburek/.nvm/versions/node/v6.7.0/lib/node_modules/plv8x/bin/plv8x:2:1)
    at Module._compile (module.js:556:32)
    at Object.Module._extensions..js (module.js:565:10)
    at Module.load (module.js:473:32)
    at tryModuleLoad (module.js:432:12)
    at Function.Module._load (module.js:424:3)
```

What am I doing with my life?

OK So let's actually follow the [README on github](https://github.com/clkao/plv8x#install-plv8x)

```
gburek@gburek-ltm2:~/code
> git clone git://github.com/clkao/plv8x.git; cd plv8x
Cloning into 'plv8x'...
remote: Counting objects: 1091, done.
remote: Total 1091 (delta 0), reused 0 (delta 0), pack-reused 1091
Receiving objects: 100% (1091/1091), 188.83 KiB | 0 bytes/s, done.
Resolving deltas: 100% (564/564), done.
Checking connectivity... done.

gburek@gburek-ltm2:~/code/plv8x
> npm i -g .

> plv8x@0.7.0 prepublish /Users/gburek/code/plv8x
> env PATH="./node_modules/.bin:$PATH" lsc -cj package.ls &&
env PATH="./node_modules/.bin:$PATH" lsc -bc -o lib src

env: lsc: No such file or directory

npm ERR! addLocal Could not install /Users/gburek/code/plv8x
npm ERR! Darwin 15.6.0
npm ERR! argv "/Users/gburek/.nvm/versions/node/v6.7.0/bin/node" "/Users/gburek/.nvm/versions/node/v6.7.0/bin/npm" "i" "-g" "."
npm ERR! node v6.7.0
npm ERR! npm  v3.10.3
npm ERR! file sh
npm ERR! code ELIFECYCLE
npm ERR! errno ENOENT
npm ERR! syscall spawn
npm ERR! plv8x@0.7.0 prepublish: `env PATH="./node_modules/.bin:$PATH" lsc -cj package.ls &&
npm ERR! env PATH="./node_modules/.bin:$PATH" lsc -bc -o lib src`
npm ERR! spawn ENOENT
npm ERR!
npm ERR! Failed at the plv8x@0.7.0 prepublish script 'env PATH="./node_modules/.bin:$PATH" lsc -cj package.ls &&
npm ERR! env PATH="./node_modules/.bin:$PATH" lsc -bc -o lib src'.
npm ERR! Make sure you have the latest version of node.js and npm installed.
npm ERR! If you do, this is most likely a problem with the plv8x package,
npm ERR! not with npm itself.
npm ERR! Tell the author that this fails on your system:
npm ERR!     env PATH="./node_modules/.bin:$PATH" lsc -cj package.ls &&
npm ERR! env PATH="./node_modules/.bin:$PATH" lsc -bc -o lib src
npm ERR! You can get information on how to open an issue for this project with:
npm ERR!     npm bugs plv8x
npm ERR! Or if that isn't available, you can get their info via:
npm ERR!     npm owner ls plv8x
npm ERR! There is likely additional logging output above.

npm ERR! Please include the following file with any support request:
npm ERR!     /Users/gburek/code/plv8x/npm-debug.log
```

Welp. Maybe it needs to be installed locally?

```
gburek@gburek-ltm2:~/code/plv8x
> npm install
npm WARN deprecated minimatch@2.0.10: Please update to minimatch 3.0.2 or higher to avoid a RegExp DoS issue
npm WARN deprecated to-iso-string@0.0.2: to-iso-string has been deprecated, use @segment/to-iso-string instead.
npm WARN deprecated jade@0.26.3: Jade has been renamed to pug, please install the latest version of pug instead of jade
npm WARN deprecated minimatch@0.3.0: Please update to minimatch 3.0.2 or higher to avoid a RegExp DoS issue

> libpq@1.8.5 install /Users/gburek/code/plv8x/node_modules/libpq
> node-gyp rebuild

gyp WARN download NVM_NODEJS_ORG_MIRROR is deprecated and will be removed in node-gyp v4, please use NODEJS_ORG_MIRROR
gyp WARN download NVM_NODEJS_ORG_MIRROR is deprecated and will be removed in node-gyp v4, please use NODEJS_ORG_MIRROR
gyp WARN download NVM_NODEJS_ORG_MIRROR is deprecated and will be removed in node-gyp v4, please use NODEJS_ORG_MIRROR
  CXX(target) Release/obj.target/addon/src/connection.o
  CXX(target) Release/obj.target/addon/src/connect-async-worker.o
  CXX(target) Release/obj.target/addon/src/addon.o
  SOLINK_MODULE(target) Release/addon.node
clang: warning: libstdc++ is deprecated; move to libc++ with a minimum deployment target of OS X 10.9

> plv8x@0.7.0 prepublish /Users/gburek/code/plv8x
> env PATH="./node_modules/.bin:$PATH" lsc -cj package.ls &&
env PATH="./node_modules/.bin:$PATH" lsc -bc -o lib src

plv8x@0.7.0 /Users/gburek/code/plv8x
...
gburek@gburek-ltm2:~/code/plv8x
> find . -name plv8x
./bin/plv8x
```

</details>

```
gburek@gburek-ltm2:~/code/plv8x
> ./bin/plv8x -l
plv8x: 392.33 kB
```

YES IT WORKS. Who would have guessed this npm module was only usable when
executed directly in its source tree and installed both locally and globally?

Let's see what is happening on the db (Heroku per line logging preamble
omitted):

```
gburek@gburek-ltm2:~/code/pg-twitter
> heroku logs -t
[15-1] LOG:  statement:
[15-2]  SET client_min_messages TO WARNING;
[15-3]  DO $PLV8X_EOF$ BEGIN
[15-4]
[15-5]  DROP FUNCTION IF EXISTS plv8x.json_eval (code text,data plv8x.json) CASCADE;
[15-6]  EXCEPTION WHEN OTHERS THEN END; $PLV8X_EOF$;
[15-7]
[15-8]  CREATE FUNCTION plv8x.json_eval (code text,data plv8x.json) RETURNS plv8x.json AS $PLV8X__BODY__$
[15-9]  if (typeof plv8x == 'undefined') plv8.execute('select plv8x.boot()', []);;
[15-10]         return JSON.stringify((eval(function (code, data){
[15-11]               return eval(plv8x.xpressionToBody(code)).apply(data);
[15-12]             }))(code,JSON.parse(data)));
[15-13]         $PLV8X__BODY__$ LANGUAGE plv8 IMMUTABLE STRICT;
[16-1] NOTICE:  drop cascades to operator <|(text,plv8x.json)
[16-2] CONTEXT:  SQL statement "DROP FUNCTION IF EXISTS plv8x.json_eval (code text,data plv8x.json) CASCADE"
[16-3]  PL/pgSQL function inline_code_block line 3 at SQL statement
[17-1] LOG:  statement:
[17-2]  SET client_min_messages TO WARNING;
[17-3]  DO $PLV8X_EOF$ BEGIN
[17-4]
[17-5]  DROP FUNCTION IF EXISTS plv8x.json_eval_ls (code text) CASCADE;
[17-6]  EXCEPTION WHEN OTHERS THEN END; $PLV8X_EOF$;
[17-7]
[17-8]  CREATE FUNCTION plv8x.json_eval_ls (code text) RETURNS plv8x.json AS $PLV8X__BODY__$
[17-9]  if (typeof plv8x == 'undefined') plv8.execute('select plv8x.boot()', []);;
[17-10]         return JSON.stringify((eval(function (code){
[17-11]               return eval(plv8x.xpressionToBody("~>" + code)).apply(this);
[17-12]             }))(code));
[17-13]         $PLV8X__BODY__$ LANGUAGE plv8 IMMUTABLE STRICT;
[18-1] NOTICE:  drop cascades to operator ~>(NONE,text)
[18-2] CONTEXT:  SQL statement "DROP FUNCTION IF EXISTS plv8x.json_eval_ls (code text) CASCADE"
[18-3]  PL/pgSQL function inline_code_block line 3 at SQL statement
[19-1] LOG:  statement:
[19-2]  SET client_min_messages TO WARNING;
[19-3]  DO $PLV8X_EOF$ BEGIN
[19-4]
[19-5]  DROP FUNCTION IF EXISTS plv8x.json_eval_ls (data plv8x.json,code text) CASCADE;
[19-6]  EXCEPTION WHEN OTHERS THEN END; $PLV8X_EOF$;
[19-7]
[19-8]  CREATE FUNCTION plv8x.json_eval_ls (data plv8x.json,code text) RETURNS plv8x.json AS $PLV8X__BODY__$
[19-9]  if (typeof plv8x == 'undefined') plv8.execute('select plv8x.boot()', []);;
[19-10]         return JSON.stringify((eval(function (data, code){
[19-11]               return eval(plv8x.xpressionToBody("~>" + code)).apply(data);
[19-12]             }))(JSON.parse(data),code));
[19-13]         $PLV8X__BODY__$ LANGUAGE plv8 IMMUTABLE STRICT;
[20-1] NOTICE:  drop cascades to operator ~>(plv8x.json,text)
[20-2] CONTEXT:  SQL statement "DROP FUNCTION IF EXISTS plv8x.json_eval_ls (data plv8x.json,code text) CASCADE"
[20-3]  PL/pgSQL function inline_code_block line 3 at SQL statement
[21-1] LOG:  statement:
[21-2]  SET client_min_messages TO WARNING;
[21-3]  DO $PLV8X_EOF$ BEGIN
[21-4]
[21-5]  DROP FUNCTION IF EXISTS plv8x.json_eval_ls (code text,data plv8x.json) CASCADE;
[21-6]  EXCEPTION WHEN OTHERS THEN END; $PLV8X_EOF$;
[21-7]
[21-8]  CREATE FUNCTION plv8x.json_eval_ls (code text,data plv8x.json) RETURNS plv8x.json AS $PLV8X__BODY__$
[21-9]  if (typeof plv8x == 'undefined') plv8.execute('select plv8x.boot()', []);;
[21-10]         return JSON.stringify((eval(function (code, data){
[21-11]               return eval(plv8x.xpressionToBody("~>" + code)).apply(data);
[21-12]             }))(code,JSON.parse(data)));
[21-13]         $PLV8X__BODY__$ LANGUAGE plv8 IMMUTABLE STRICT;
[22-1] NOTICE:  drop cascades to operator <~(text,plv8x.json)
[22-2] CONTEXT:  SQL statement "DROP FUNCTION IF EXISTS plv8x.json_eval_ls (code text,data plv8x.json) CASCADE"
[22-3]  PL/pgSQL function inline_code_block line 3 at SQL statement
[23-1] LOG:  statement: DROP OPERATOR IF EXISTS |> (NONE, text); CREATE OPERATOR |> (
[23-2]      RIGHTARG = text,
[23-3]      PROCEDURE = plv8x.json_eval
[23-4]  );
[23-5]  DROP OPERATOR IF EXISTS |> (plv8x.json, text); CREATE OPERATOR |> (
[23-6]      LEFTARG = plv8x.json,
[23-7]      RIGHTARG = text,
[23-8]      COMMUTATOR = <|,
[23-15]             PROCEDURE = plv8x.json_eval
[23-10]         );
[23-9]      PROCEDURE = plv8x.json_eval
[23-16]         );
[23-14]             COMMUTATOR = |>,
[23-17]
[23-13]             RIGHTARG = plv8x.json,
[23-18]         DROP OPERATOR IF EXISTS ~> (NONE, text); CREATE OPERATOR ~> (
[23-11]         DROP OPERATOR IF EXISTS <| (text, plv8x.json); CREATE OPERATOR <| (
[23-19]             RIGHTARG = text,
[23-12]             LEFTARG = text,
[23-20]             PROCEDURE = plv8x.json_eval_ls
[23-21]         );
[23-22]         DROP OPERATOR IF EXISTS ~> (plv8x.json, text); CREATE OPERATOR ~> (
[23-23]             LEFTARG = plv8x.json,
[23-24]             RIGHTARG = text,
[23-25]             COMMUTATOR = <~,
[23-27]         );
[23-26]             PROCEDURE = plv8x.json_eval_ls
[23-28]         DROP OPERATOR IF EXISTS <~ (text, plv8x.json); CREATE OPERATOR <~ (
[23-29]             LEFTARG = text,
[23-30]             RIGHTARG = plv8x.json,
[23-31]             COMMUTATOR = ~>,
[23-32]             PROCEDURE = plv8x.json_eval_ls
[23-33]         );
[24-1] NOTICE:  operator |> does not exist, skipping
[25-1] NOTICE:  operator |> does not exist, skipping
[26-1] NOTICE:  operator ~> does not exist, skipping
[27-1] NOTICE:  operator ~> does not exist, skipping
```

This is not great. It seems that `plv8x` wants to create custom operators that
are similar to ones in Livescript (`|>` pipeline operator) and CoffeeScript
(`->` thin arrows which are translated as `~>`).

~~Custom operators are superuser only and run the risk of crashing the
postmaster, so many Postgres providers do not support them.~~

~~However, it seems that they are not critical to using vanilla js and node, so
we may continue.~~

### *UPDATE:* Only custom *default* operators seem to not work. After altering the search_path of the db, these appear to be created properly.

```
> select * from pg_operator where oprcode::text ilike 'plv8%';
 oprname | oprnamespace | oprowner | oprkind | oprcanmerge | oprcanhash | oprleft | oprright | oprresult | oprcom | oprnegate |      oprcode       | oprrest | oprjoin
---------+--------------+----------+---------+-------------+------------+---------+----------+-----------+--------+-----------+--------------------+---------+---------
 |>      |        17017 |    16384 | l       | f           | f          |       0 |       25 |     17027 |      0 |         0 | plv8x.json_eval    | -       | -
 |>      |        17017 |    16384 | b       | f           | f          |   17027 |       25 |     17027 |  17316 |         0 | plv8x.json_eval    | -       | -
 <|      |        17017 |    16384 | b       | f           | f          |      25 |    17027 |     17027 |  17317 |         0 | plv8x.json_eval    | -       | -
 ~>      |        17017 |    16384 | l       | f           | f          |       0 |       25 |     17027 |      0 |         0 | plv8x.json_eval_ls | -       | -
 ~>      |        17017 |    16384 | b       | f           | f          |   17027 |       25 |     17027 |  17320 |         0 | plv8x.json_eval_ls | -       | -
 <~      |        17017 |    16384 | b       | f           | f          |      25 |    17027 |     17027 |  17321 |         0 | plv8x.json_eval_ls | -       | -
(6 rows)
```

## How does this work?

Let's take a look at the db:

```
> \dn
     List of schemas
  Name  |     Owner
--------+----------------
 plv8x  | uah8s1lfn60k9k
 public | uah8s1lfn60k9k
(2 rows)

> \d plv8x.
                 Table "plv8x.code"
  Column  |            Type             | Modifiers
----------+-----------------------------+-----------
 name     | text                        | not null
 code     | text                        |
 load_seq | integer                     |
 updated  | timestamp without time zone |
Indexes:
    "code_pkey" PRIMARY KEY, btree (name)

  Index "plv8x.code_pkey"
 Column | Type | Definition
--------+------+------------
 name   | text | name
primary key, btree, for table "plv8x.code"

> \d plv8x.code
                 Table "plv8x.code"
  Column  |            Type             | Modifiers
----------+-----------------------------+-----------
 name     | text                        | not null
 code     | text                        |
 load_seq | integer                     |
 updated  | timestamp without time zone |
Indexes:
    "code_pkey" PRIMARY KEY, btree (name)
```

Wow, ok so node modules are rows in this table?

```
> select name, substring(code from 1 for 1300), load_seq, updated from plv8x.code;
-[ RECORD 1 ]----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
name      | plv8x
substring | !function(e){if("object"==typeof exports&&"undefined"!=typeof module)module.exports=e();else if("function"==typeof define&&define.amd)define([],e);else{var f;"undefined"!=typeof window?f=window:"undefined"!=typeof global?f=global:"undefined"!=typeof self&&(f=self),f.plv8x=e()}}(function(){var define,module,exports;return (function e(t,n,r){function s(o,u){if(!n[o]){if(!t[o]){var a=typeof require=="function"&&require;if(!u&&a)return a(o,!0);if(i)return i(o,!0);var f=new Error("Cannot find module '"+o+"'");throw f.code="MODULE_NOT_FOUND",f}var l=n[o]={exports:{}};t[o][0].call(l.exports,function(e){var n=t[o][1][e];return s(n?n:e)},l,l.exports,e,t,n,r)}return n[o].exports}var i=typeof require=="function"&&require;for(var o=0;o<r.length;o++)s(r[o]);return s})({1:[function(require,module,exports){+
          | // Generated by LiveScript 1.2.0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   +
          | var ref$, _mk_func, compileCoffeescript, compileLivescript, xpressionToBody, plv8xSql, operatorsSql, _eval, _apply, _require, _mk_json_eval, _mk_json_eval_ls, _boot;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              +
          | ref$ = require('..'), _mk_func = ref$._mk_func, compileCoffeescript = ref$.compileCoffeescript, compileLivescript = ref$.compileLivescript, xpressionToBody = ref$.xpressionToBody;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                +
          | ref$ = require('./sql'), plv8xSql = ref$.plv8xSql, operatorsSql = ref$.operatorsSql;                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               +
          | module.exports = function(drop,
load_seq  |
updated   | 2016-10-08 16:27:59

```

Not even minified. Cool.


## Install a node package into the db

Let's install something.

```
gburek@gburek-ltm2:~/code/plv8x
> ./bin/plv8x -i twitter-node-client

gburek@gburek-ltm2:~/code/plv8x
> ./bin/plv8x -l
plv8x: 392.33 kB
twitter-node-client: 685.9 kB

> select name, octet_length(code), load_seq, updated from plv8x.code;
        name         | octet_length | load_seq |       updated
---------------------+--------------+----------+---------------------
 plv8x               |       392331 |          | 2016-10-08 16:27:59
 twitter-node-client |       685900 |          | 2016-10-11 17:20:21
(2 rows)
```

Cool. What about running something simple?

```
gburek@gburek-ltm2:~/code/plv8x
> ./bin/plv8x -e 'require("qs").parse("foo=bar&baz=1")'
WARNING:  failed to load module buffer:
WARNING:  failed to load module qs: Error: no window object present
WARNING:  Error: no window object present
    at eval (eval at <anonymous> (boot:27:23), <anonymous>:16168:15)
    at Object../lib/request (eval at <anonymous> (boot:27:23), <anonymous>:16200:3)
    at s (eval at <anonymous> (boot:27:23), <anony
/Users/gburek/code/plv8x/lib/index.js:29
        throw err;
        ^

Error: ERROR:  TypeError: Cannot call method 'parse' of undefined
DETAIL:  undefined() LINE 0: ((function(){return require("qs").parse("foo=bar&baz=1")}))()

    at Client._readError (/Users/gburek/code/plv8x/node_modules/pg-native/index.js:80:13)
    at Client._read (/Users/gburek/code/plv8x/node_modules/pg-native/index.js:121:19)
    at emitNone (events.js:86:13)
    at PQ.emit (events.js:185:7)
```

This isn't good. What about defining a function?

```
gburek@gburek-ltm2:~/code/plv8x
> ./bin/plv8x -f 'plv8x.json parse_qs(text)=qs:parse'
ok plv8x.json parse_qs(text)

> SELECT parse_qs('foo=bar&baz=1') AS qs;
WARNING:  01000: failed to load module buffer:
LOCATION:  plv8_Elog, plv8_func.cc:327
WARNING:  01000: failed to load module qs: Error: no window object present
LOCATION:  plv8_Elog, plv8_func.cc:327
WARNING:  01000: Error: no window object present
    at eval (eval at <anonymous> (boot:27:23), <anonymous>:16168:15)
    at Object../lib/request (eval at <anonymous> (boot:27:23), <anonymous>:16200:3)
    at s (eval at <anonymous> (boot:27:23), <anony
LOCATION:  plv8_Elog, plv8_func.cc:327
ERROR:  XX000: TypeError: Cannot read property 'parse' of undefined
DETAIL:  parse_qs() LINE 4:   return plv8x.require('qs').parse.apply(this, arguments);
LOCATION:  rethrow, plv8.cc:1649
```

It looks like the lack of custom operators is preventing this code from
running.

# Failure?

### UPDATE: It seems that the search path of the db was not wide enough, and including all possible schemas, allows operator creation and for modules to be loaded and run:

```
> alter database df5f7ilg16vje set search_path to "$user", public, plv8, plv8x;
ALTER DATABASE
Time: 79.494 ms
> SELECT |>'(require("moment")()).format()';
          ?column?
-----------------------------
 "2016-10-12T20:30:26+00:00"
(1 row)

Time: 76.703 ms
```

Part 2 will continue down this path to running node/npm in Postgres and will
show how the above was found.

~~After all this exploration, I think using plv8x with a Heroku Postgres db is
not possible. The use of custom operators seems to extend beyond the ability to
use LiveScript and Coffeescript and prevents loading vanilla modules.~~

~~I am not too discouraged, however, as
[node-plv8](https://github.com/langateam/node-plv8) and
[plv8-bedrock](https://github.com/mgutz/plv8-bedrock) seem like viable
alternatives. I'll try those next!~~
