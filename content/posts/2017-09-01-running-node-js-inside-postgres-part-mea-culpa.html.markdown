---

title: Running Node.js inside Postgres, Part Mea Culpa
date: "2017-09-01"
tags: [ node, npm, postgres, nodejs, discovery, plv8, plv8x, mea culpa ]
---

[Previously](/2016/10/08/running-node-js-inside-postgres-part-1), I wrote about
trying to run node.js code in PLV8 in Postgres. Unfortunately, that effort
sputtered out once I
[found](https://stackoverflow.com/questions/12666148/does-plv8-support-making-http-calls-to-other-servers)
[out](https://github.com/plv8/plv8/issues/190)
that PLV8 is a 'trusted' languagefor postgres. As documented for
[PL/Perl](https://www.postgresql.org/docs/current/static/plperl-trusted.html):

> Normally, PL/Perl is installed as a "trusted" programming language named
> plperl. In this setup, certain Perl operations are disabled to preserve
> security. In general, the operations that are restricted are those that
> interact with the environment. This includes file handle operations, require,
> and use (for external modules). There is no way to access internals of the
> database server process or to gain OS-level access with the permissions of
> the server process, as a C function can do. Thus, any unprivileged database
> user can be permitted to use this language.

So, no filesystem access means no unix socket access, which means no network
access. `¯\_(ツ)_/¯`

If [plv8u](https://github.com/plv8/plv8/issues/222) lands, I can revisit my
previous goal, but until then...
