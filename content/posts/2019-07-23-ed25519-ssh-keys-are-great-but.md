---
title: "Ed25519 SSH Keys Are Great, But Barriers Remain"
date: 2019-07-23T16:23:17-07:00
---

Last year, I read a blog post that urged me to [Upgrade Your SSH Key to
Ed25519](https://medium.com/risan/upgrade-your-ssh-key-to-ed25519-c6e8d60d3c54)
and so I did. Ed25519 keys have been available since OpenSSH 6.5 (OpenSSH 8.0
was released on 2019-04-17), and they are smaller, faster and better than RSA,
it seems. More info is in the blog post.

However, many months later, I found that ed25519 keys are not well supported for
a few key systems:

1. Unifi network devices allow you to [provide SSH keys in the CloudKey
   UI](https://help.ubnt.com/hc/en-us/articles/235247068-UniFi-Adding-SSH-Keys-to-UniFi-Devices)
   to be distributed to your network devices, but the UI only accepts some types
   of keys. At the moment, [Unifi CloudKey, AP, and USG all support ed25519
   keys on the hardware, but the CloudKey UI rejects
   them](https://community.ui.com/questions/UCK-Firmware-GUI-SSH-Key-Minor-Feature-Request-/b888e182-a029-460d-941d-91de3812829c#answer/1910a856-123d-4a57-91ea-286d98740959).
2. [Dropbear](https://matt.ucc.asn.au/dropbear/dropbear.html), which you can run
   inside of [initramfs](https://packages.debian.org/buster/dropbear-initramfs)
   to [remotely unlock encrypted Linux
   filesystems](https://hamy.io/post/0009/how-to-install-luks-encrypted-ubuntu-18.04.x-server-and-enable-remote-unlocking/),
   [does not seem to support
   ed25519](https://hamy.io/post/0009/how-to-install-luks-encrypted-ubuntu-18.04.x-server-and-enable-remote-unlocking/#fn:3).
   An [HN comment](https://news.ycombinator.com/item?id=17765549) from 11 months
   ago suggests a fix is in the works, but nothing about ed25519 has appeared in
   the [changelog](https://matt.ucc.asn.au/dropbear/CHANGES).

Admittedly, these issues are not total show stoppers and I could use ed25519
keys for normal access and RSA keys for network device access and when my linux
box reboots. It's just that juggling ed25519 and RSA keys for all my iOS devices
([Blink is great](https://www.blink.sh/)), a linux workstation, raspberry pis
and several laptops, seeding them correctly, managing passphrases and
configuring clients to use the right ones is complicated.

There already is an open feature request for ed25519 keys in the [Unifi
UI](https://community.ui.com/questions/UCK-Firmware-GUI-SSH-Key-Minor-Feature-Request-/b888e182-a029-460d-941d-91de3812829c#answer/1910a856-123d-4a57-91ea-286d98740959)
and an unreviewed PR for [Dropbear](https://github.com/mkj/dropbear/pull/75),
but we build systems with what we have, not what is on the roadmap.

If you are looking at ed25519 keys for your infra, they are fine and good,
except for the unifi and Dropbear edge cases. You could probably work around
them by deploying a
[config.gateway.json](https://help.ubnt.com/hc/en-us/articles/215458888-UniFi-USG-Advanced-Configuration)
and applying the [Dropbear patch](https://github.com/mkj/dropbear/pull/75)
manually, but that sounds as exhausting as managing RSA and ed25519 keys, so we
have a cure which becomes an ailment.

So, for now, I'm following [Github's
docs](https://help.github.com/en/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)
and using 4096 bit RSA keys, as well as Github's public key "feature"
(https://github.com/username.keys) to seed [authorized_keys from
Ansible](https://docs.ansible.com/ansible/latest/modules/authorized_key_module.html)
through out my infra.

It's fine.

### Postscript

[Screens for iOS](https://edovia.com/en/screens-ios/) can connect to VNC via a
[secure
connection](https://help.edovia.com/hc/en-us/articles/115011943907-Configuring-a-Secure-Connection-in-Screens)
which appears to use an SSH tunnel.
While you can use [SSH
keys](https://help.edovia.com/hc/en-us/articles/115005876368-SSH-Keys) for
authentication, ed25519 keys not supported and one can only use
["...RSA keys of 2048-bits or less; 4096-bits or greater are
unsupported"](https://help.edovia.com/hc/en-us/articles/115005876368-SSH-Keys).
This is less than ideal and I'll revisit Screens, if I get a desktop on linux
that is worth using VNC for.

### Post-postscript (August 5, 2019)

[Linux VMs in
Azure](https://docs.microsoft.com/en-us/azure/virtual-machines/linux/mac-create-ssh-keys)
also do not support ed25519 keys.

> Azure currently supports SSH protocol 2 (SSH-2) RSA public-private key pairs
> with a minimum length of 2048 bits. Other key formats such as ED25519 and
> ECDSA are not supported.

[A friend alleges](https://twitter.com/danfarina/status/1154855746628009984)
that Azure Devops also does not support ed25519 keys, but the product name gives
me heartburn and makes it difficult to find docs that confirm this.
