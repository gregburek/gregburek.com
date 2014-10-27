---
title: Require HTTPS to your Heroku app
date: 2014-10-26 15:29 PDT
tags:
---

Configuring your Heroku app so that it will redirect insecure HTTP traffic to an
HTTPS endpoint can be finicky and is language/framework specific. I was able to
figure out a general and language independent method thanks to the [nginx
buildpack](https://github.com/ryandotsmith/nginx-buildpack). By using nginx,
you can redirect some or all http traffic to your app to the https verison of
your site.

By adding:

```
if ($http_x_forwarded_proto != 'https') {
  rewrite ^ https://$host$request_uri? permanent;
}
```

to the `location` section of your app's nginx config file template, any access
to that location will be met with a `301 Moved Permanently` redirect to the
`https` version of that site and path.

EDIT: @jacobian [pointed
out](https://twitter.com/jacobian/status/526538110201368576) on twitter that
using HTTP Strict Transport Security
(HSTS)](http://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) headers
will make modern clients prefer HTTPS, even for the `/insecure` path that lacks
the redirect snippet.

As all apps are accessible at `https://<app-name>.herokuapp.com/` by using
Heroku's `herokuapp.com` SSL cert, this provides a free and easy way to secure
your apps. Custom domain names require custom SSL certs, which are available
from traditional SSL vendors or from Heroku addon [Expedited
SSL](https://www.expeditedssl.com/)

A sample app can be found at
[https://github.com/gregburek/heroku-force-ssl-sample](https://github.com/gregburek/heroku-force-ssl-sample)
and deployed to your Heroku account here: 
[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/gregburek/heroku-force-ssl-sample)


