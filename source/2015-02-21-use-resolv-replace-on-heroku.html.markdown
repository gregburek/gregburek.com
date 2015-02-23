---
title: DNS, eglibc and resolv-replace on Heroku
date: 2015-02-21 15:33 PST
tags: heroku, ruby, libc, dns, yaks
published: false
---

I work on the team that runs [Heroku Postgres]. As we have continued to grow, I
have been tracking an intermitent error with [Rollbar][] that occurs about once
every 50,000 HTTP requests. As we are doing many hundreds of thousands of API
calls a minute to various services, this error can pop up fairly frequently and
in very inconvenient places. The most common traceback seems to indicate a
failure to resolve DNS:

```ruby
#<SocketError: getaddrinfo: Name or service not known>
/app/vendor/ruby-2.1.5/lib/ruby/2.1.0/net/http.rb:879:in 'initialize'
/app/vendor/ruby-2.1.5/lib/ruby/2.1.0/net/http.rb:879:in 'open'
/app/vendor/ruby-2.1.5/lib/ruby/2.1.0/net/http.rb:879:in 'block in connect'
...
```

[Google][] led me to a [pertinent blog post][] that recommended using ruby's
[Resolv][] library for all DNS requests via a script called [resolv-replace][].
Adding a single line to our initializers, `require resolv-replace`, caused errors
while submitting Logplex messages to immediately drop:

![Logplex Errors][logplexerrors]

As did errors from trying to interact with our monitoring service, Observatory:

![Observatory Errors][observatoryerrors]

In an internal thread, [Ed Muller][] pointed out a [golang work around][]
of a [bug in glibc][] which is very likely to be a factor in this error:

> Under high load, getaddrinfo() starts sending DNS queries to random
file descriptors, e.g. some unrelated socket connected to a remote service.

As Heroku is a shared platform with multitenant runtime instances, it is
possible for a random runtime to experience high load and the [cedar-14 glibc
binaries][] are known to be impacted by this bug. As of version 2.20, the error
should be fixed. However, Ubuntu Precise currently ships [2.15-0ubuntu10.10][]
and Trusty provides [2.19-0ubuntu6.5][], so this bug may continue to be a
problem for some time to come.

My immediate recommendation is to use language native DNS resolution like
`resolv-replace` whenever possible, on Heroku or other systems. However, if you
require ipv6 or run into problems with [third party gems attempting to resolve
`nil` addresses][], and are stuck with the system DNS system, please indicate
that this bug affects you on the [Launchpad bug report requesting backporting][]
to supported versions of Ubuntu.



[logplexerrors]: /2015-02-21-use-resolv-replace-on-heroku/logplex_errors.png
[observatoryerrors]: /2015-02-21-use-resolv-replace-on-heroku/observatory_errors.png

[Heroku Postgres]: https://www.heroku.com/postgres
[Rollbar]: https://devcenter.heroku.com/articles/rollbar
[pertinent blog post]: http://www.subelsky.com/2014/05/fixing-socketerror-getaddrinfo-name-or.html
[Google]: http://lmgtfy.com/?q=SocketError%3A+getaddrinfo%3A+Name+or+service+not+known+heroku
[Resolv]: http://apidock.com/ruby/Resolv
[Ed Muller]: https://twitter.com/freeformz
[golang work around]: https://github.com/golang/go/issues/6336#issuecomment-66085142
[bug in glibc]: https://sourceware.org/bugzilla/show_bug.cgi?id=15946
[resolv-replace]: https://github.com/ruby/ruby/blob/trunk/lib/resolv-replace.rb
[2.15-0ubuntu10.10]: http://packages.ubuntu.com/precise-updates/libc6
[2.19-0ubuntu6.5]: http://packages.ubuntu.com/trusty-updates/libc6
[cedar-14 glibc binaries]: https://devcenter.heroku.com/articles/cedar-ubuntu-packages
[vote]: https://bugs.launchpad.net/eglibc/+bug/1421393
[Launchpad bug report requesting backporting]: https://bugs.launchpad.net/eglibc/+bug/1421393
[third party gems attempting to resolve `nil` addresses]: https://github.com/mperham/sidekiq/issues/1258#issuecomment-27389456
