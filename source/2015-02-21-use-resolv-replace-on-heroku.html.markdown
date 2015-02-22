---
title: Use resolv-replace on Heroku
date: 2015-02-21 15:33 PST
tags: heroku, ruby, libc, dns, yaks
---

tl;dr Use native language DNS resolvers on Heroku, like `resolv-replace` with ruby.

### Microservices ༼ ༎ຶ ෴ ༎ຶ༽

I work on the team that runs [Heroku Postgres]. In order to manage thousands of
database servers, we run some of the largest apps on Heroku. Those apps are
responsible for provisioning, configuration and monitoring of those databases,
as well as interacting with the Heroku Addons API and injecting [metrics into
logplex]. We are slowly moving to microservices, so much inter-app traffic is
via HTTPS JSON APIs. As we run Heroku apps, we are able to take advantage of
other awesome Heroku Addons, like [Rollbar][] for exception tracking and
analysis.

### Intermittent SocketErrors 🐃 🔜 🐩

As we have continued to grow, I have been tracking an intermitent error with
Rollbar that occurs about once every 50,000 HTTP requests. As we are doing many
hundreds of thousands of API calls a minute to various services, this error
can pop up fairly frequently and in very inconvenient places. The traceback
mostly seems to indicate a failure to resolve DNS:

```ruby
#<SocketError: getaddrinfo: Name or service not known>
/app/vendor/ruby-2.1.5/lib/ruby/2.1.0/net/http.rb:879:in 'initialize'
/app/vendor/ruby-2.1.5/lib/ruby/2.1.0/net/http.rb:879:in 'open'
/app/vendor/ruby-2.1.5/lib/ruby/2.1.0/net/http.rb:879:in 'block in connect'
/app/vendor/ruby-2.1.5/lib/ruby/2.1.0/timeout.rb:76:in 'timeout'
/app/vendor/ruby-2.1.5/lib/ruby/2.1.0/net/http.rb:878:in 'connect'
/app/vendor/ruby-2.1.5/lib/ruby/2.1.0/net/http.rb:863:in 'do_start'
/app/vendor/ruby-2.1.5/lib/ruby/2.1.0/net/http.rb:852:in 'start'
/app/vendor/bundle/ruby/2.1.0/gems/rest-client-1.6.8/lib/restclient/request.rb:206:in 'transmit'
/app/vendor/bundle/ruby/2.1.0/gems/rest-client-1.6.8/lib/restclient/request.rb:68:in 'execute'
/app/vendor/bundle/ruby/2.1.0/gems/rest-client-1.6.8/lib/restclient/request.rb:35:in 'execute'
/app/vendor/bundle/ruby/2.1.0/gems/rest-client-1.6.8/lib/restclient/resource.rb:51:in 'get'
...
```

[Google][] led me to a [pertinent blog post][] that recommended using ruby's
[Resolv][] library for all DNS requests. This was accomplished by adding a
single line:

```
require resolv-replace
```

The impact of this change was stark and immediate. Logplex message submission
errors immediately quieted:

![Logplex Errors][logplexerrors]

As did errors from trying to interact with our monitoring service, Observatory:

![Observatory Errors][observatoryerrors]

It seems odd that such a small change would completely solve such an error, so I
dug in more to find out what happened. 

### resolv-replace

The `resolv-replace` library has been part of ruby' standard lib for a very long
time

[logplexerrors]: /2015-02-21-use-resolv-replace-on-heroku/logplex_errors.png
[observatoryerrors]: /2015-02-21-use-resolv-replace-on-heroku/observatory_errors.png


[Heroku Postgres]: https://www.heroku.com/postgres
[metrics into logplex]: https://devcenter.heroku.com/articles/heroku-postgres-metrics-logs
[Rollbar]: https://devcenter.heroku.com/articles/rollbar
[pertinent blog post]: http://www.subelsky.com/2014/05/fixing-socketerror-getaddrinfo-name-or.html
[Google]: http://lmgtfy.com/?q=SocketError%3A+getaddrinfo%3A+Name+or+service+not+known+heroku
[Resolv]: http://apidock.com/ruby/Resolv
