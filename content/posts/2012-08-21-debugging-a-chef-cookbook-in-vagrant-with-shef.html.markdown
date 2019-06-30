---
title: "Debugging a chef cookbook in vagrant with shef"
date: "2012-08-21"
tags: [ vagrant, debugging, shef, chef, testing ]
---

Sometimes [Vagrant](http://vagrantup.com "Vagrant - Virtualized development for
the masses")'s provisioning error messages can be a little cryptic.

When troubleshooting a failing chef-solo run, tweaking a `run_list` or
debugging a new recipe, I've found it very handy to log into the partially
provisioned VM with `vagrant ssh` and then run: [Vagrant](http://vagrantup.com
"Vagrant - Virtualized development for the masses") is a great tool for
developing and testing new chef cookbooks. After bringing up a new vm, and
editing a cookbook,`vagrant provision` runs the chef-solo provisioner and tests
things out. However, when things fail, vagrant's provisioning error messages
can be a little cryptic. [Shef](http://wiki.opscode.com/display/chef/Shef "Shef
- Chef - Opscode Open Source Wiki") is a good tool for running cookbooks in
isolation, but it needs some help to find all the configuration and attributes
that vagrant provides. If my `new_and_broken` cookbook is failing on a Ubuntu
12.04 VM, all I need to do is run:

```
$ shef -s -c /tmp/vagrant-chef-1/solo.rb -j /tmp/vagrant-chef-1/dna.json
    (output snip)
chef > recipe
chef:recipe > include_recipe 'new_and_broken'
    (huge output snip)
chef:recipe > run_chef
    (where the error happens)
```

This loads shef in solo mode, with vagrant generated configuration and JSON
attributes files, enters into recipe mode, loads my new and broken cookbook and
runs it. The resulting error messages are usually more helpful than `vagrant
provision` and I can get back to work. 

