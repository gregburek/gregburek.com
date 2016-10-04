---
title: Debugging Kernel Panics on EC2
date: 2016-06-19 14:22 PDT
tags: aws linux netconsole kernel debug panic postgresql rsyslog
published: false
---

For about a year, my group at $work has stuggled with and, for a time,
deferred a major version OS upgrade due to infrequent, but repeated linux
kernel panics on a small number of customer and internal production
databases. With only occasional kernel dumps, no hardware console available in
EC2 and many instances discarded by our HA failover prodcedure, it was difficult
to debug, monitor or make bug reports. In the end, we were able to use netconsole,
rsyslog, Heroku Postgres and Heroku Dataclips to monitor and ultimately qualify a
more recent kernel for our fleet.







