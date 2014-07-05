---
title: "Using veewee 0.2 with Vagrant omnibus"
date: 2012-08-12 15:20
comments: true
categories: [vagrant, veewee, virtualization, testing]
---

I'm a huge fan of [Vagrant](http://vagrantup.com "Vagrant - Virtualized
development for the masses")'s recent omnibus style installer. It makes it so
much easier to recommend to others as they can be up and running with Vagrant
extremely quickly, instead of wondering why their distro packaged ruby
installation isn't working. However, because Vagrant is using an embedded ruby
installation, other gems which add to vagrant are unable to find it. 

One such tool is [veewee](http://github.com/jedi4ever/veewee/ "Veewee on
Github"), which makes it dead simple to automatically build VMs from
kickstarter files and basic scripts. Version 0.2 also adds a great subcommand
to Vagrant called 'basebox' which lets you use veewee to build baseboxes that
Vagrant may then use to launch new VMs. But with Vagrant being run from its own
embedded ruby environment, veewee is not able to find the vagrant gem to add
to, making it a little harder to use for ruby newbies. 

There is a way around this, though. If you were to run:

```
sudo /opt/vagrant/embedded/bin/gem install veewee --no-ri --no-rdoc
```
veewee is installed to the vagrant embedded environment and `vagrant basebox`
is available and functions as expected. I've done this on my OSX 10.8 box that
uses rbenv to manage ruby versions as well on a Ubuntu 12.04 box that uses rvm. 

Let me know if this does or doesn't work for you.
