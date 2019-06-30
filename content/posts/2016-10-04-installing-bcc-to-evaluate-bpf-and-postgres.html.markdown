---
title: Installing bcc to evaluate BPF and Postgres
date: "2016-10-04"
tags: [ bpf, postgres, linux, performance, ubuntu, discovery ]
---

[@t_crayford](https://twitter.com/t_crayford) sent me Brendan Gregg's latest
missive about performance tracing, this time for [Linux MySQL Slow Query Tracing with bcc/BPF](http://www.brendangregg.com/blog/2016-10-04/linux-bcc-mysqld-qslower.html).

READMORE

[bcc](https://github.com/iovisor/bcc) stands for 'BPF Compiler Collection' and
[BPF](https://en.wikipedia.org/wiki/Berkeley_Packet_Filter) stands for
'Berkeley Packet Filter'. From the bcc
[README](https://github.com/iovisor/bcc/blob/60393ea5dd966d33ff24929f6981df09473cbb1b/README.md):

> BCC is a toolkit for creating efficient kernel tracing and manipulation
> programs, and includes several useful tools and examples. It makes use of
> extended BPF (Berkeley Packet Filters), formally known as eBPF, a new feature
> that was first added to Linux 3.15. Much of what BCC uses requires Linux 4.1
> and above.

> eBPF was [described](https://lkml.org/lkml/2015/4/14/232) by Ingo Molnár as:

>> One of the more interesting features in this cycle is the ability to attach
>> eBPF programs (user-defined, sandboxed bytecode executed by the kernel) to
>> kprobes. This allows user-defined instrumentation on a live kernel image
>> that can never crash, hang or interfere with the kernel negatively.

> BCC makes BPF programs easier to write, with kernel instrumentation in C (and
> includes a C wrapper around LLVM), and front-ends in Python and lua. It is
> suited for many tasks, including performance analysis and network traffic
> control.

As I work for Heroku Postgres, I wanted to investigate something similar for
Postgres, running on our infrastructure. First thing to check was if it was
even possible on our systems, using [bcc's INSTALL
instructions](https://github.com/iovisor/bcc/blob/60393ea5dd966d33ff24929f6981df09473cbb1b/INSTALL.md).

New Postgres databases get Ubuntu Trusty instances with
`linux-generic-lts-xenial` kernels of the 4.4 series:

```
=> select version();
                                             version
-------------------------------------------------------------------------------------------------
 PostgreSQL 9.5.4 on x86_64-pc-linux-gnu, compiled by gcc (Ubuntu 4.8.2-19ubuntu1) 4.8.2, 64-bit
(1 row)
```

```
~$ uname -a
Linux ip-10-0-10-230 4.4.0-38-generic #57~14.04.1-Ubuntu SMP Tue Sep 6 17:20:43 UTC 2016 x86_64 x86_64 x86_64 GNU/Linux
```

This seems to satisfy the `Linux kernel version 4.1 or newer` requirement.

Next thing to check is if the kernel has been compiled properly:

```
~$ cat /boot/config-4.4.0-38-generic | grep BPF
CONFIG_BPF=y
CONFIG_BPF_SYSCALL=y
CONFIG_NETFILTER_XT_MATCH_BPF=m
CONFIG_NET_CLS_BPF=m
CONFIG_NET_ACT_BPF=m
CONFIG_BPF_JIT=y
CONFIG_HAVE_BPF_JIT=y
CONFIG_BPF_EVENTS=y
CONFIG_TEST_BPF=m
```

This looks ok! Next up is to install the repo and tools:

```
~$ sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D4284CDD
...
gpg: requesting key D4284CDD from hkp server keyserver.ubuntu.com
gpg: key D4284CDD: public key "Brenden Blanco <bblanco@plumgrid.com>" imported
gpg: Total number processed: 1
gpg:               imported: 1  (RSA: 1)
~$ echo "deb https://repo.iovisor.org/apt trusty main" | sudo tee /etc/apt/sources.list.d/iovisor.list
deb https://repo.iovisor.org/apt trusty main
~$ sudo apt-get update
...
Fetched 4,322 kB in 3s (1,269 kB/s)
Reading package lists... Done
~$ sudo apt-get install binutils bcc bcc-tools libbcc-examples python-bcc
Reading package lists... Done
Building dependency tree
Reading state information... Done
binutils is already the newest version.
binutils set to manually installed.
The following extra packages will be installed:
  bin86 elks-libc libbcc
The following NEW packages will be installed:
  bcc bcc-tools bin86 elks-libc libbcc libbcc-examples python-bcc
0 upgraded, 7 newly installed, 0 to remove and 30 not upgraded.
Need to get 10.4 MB of archives.
After this operation, 36.6 MB of additional disk space will be used.
Do you want to continue? [Y/n] y
...
~$
```

Now to test this out:

```
# /usr/share/bcc/tools/tplist -l /usr/lib/postgresql/9.5/bin/postgres
Traceback (most recent call last):
  File "/usr/share/bcc/tools/tplist", line 16, in <module>
    from bcc import USDTReader
ImportError: cannot import name USDTReader
```

Welp. Looking at the source of [tplist on current master](https://github.com/iovisor/bcc/blob/6e60fbc8a672d8f29cab688ddc0df6d43a96c300/tools/tplist.py),
the [most recent commit](https://github.com/iovisor/bcc/commit/69e361ac66fbf3baadb1f7cf21762df61ad7a5a9#diff-8189c35f15538919a795b3f18ad0db66L16)
removes `USDTReader`. Time to try the nightly builds:

```
~$ echo "deb [trusted=yes] https://repo.iovisor.org/apt/trusty trusty-nightly main" | sudo tee /etc/apt/sources.list.d/iovisor.list
~$ sudo apt-get update
~$ sudo apt-get install bcc-tools
~$ sudo /usr/share/bcc/tools/tplist -l /usr/lib/postgresql/9.5/bin/postgres
'USDT' object has no attribute 'enumerate_probes'
```

Welp. `enumerate_probes` was added in another part of the [above patch](https://github.com/iovisor/bcc/commit/69e361ac66fbf3baadb1f7cf21762df61ad7a5a9#diff-4cf0bde404ce4b67b2961b61419fa23fR58), so I think other things
need to be updated, as well.

```
~$ sudo apt-get install binutils bcc bcc-tools libbcc-examples python-bcc
Reading package lists... Done
Building dependency tree
Reading state information... Done
bcc is already the newest version.
binutils is already the newest version.
bcc-tools is already the newest version.
The following packages will be upgraded:
  libbcc-examples python-bcc
2 upgraded, 0 newly installed, 0 to remove and 31 not upgraded.
Need to get 302 kB of archives.
After this operation, 6,144 B of additional disk space will be used.
Do you want to continue? [Y/n] y
Get:1 https://repo.iovisor.org/apt/trusty/ trusty-nightly/main libbcc-examples amd64 0.2.0-22.git.12a09dc [267 kB]
Get:2 https://repo.iovisor.org/apt/trusty/ trusty-nightly/main python-bcc all 0.2.0-22.git.12a09dc [34.3 kB]
Fetched 302 kB in 0s (319 kB/s)
(Reading database ... 91427 files and directories currently installed.)
Preparing to unpack .../libbcc-examples_0.2.0-22.git.12a09dc_amd64.deb ...
Unpacking libbcc-examples (0.2.0-22.git.12a09dc) over (0.2.0-1) ...
Preparing to unpack .../python-bcc_0.2.0-22.git.12a09dc_all.deb ...
Unpacking python-bcc (0.2.0-22.git.12a09dc) over (0.2.0-1) ...
Setting up libbcc-examples (0.2.0-22.git.12a09dc) ...
Setting up python-bcc (0.2.0-22.git.12a09dc) ...
~$ less /usr/lib/python2.7/dist-packages/bcc/usdt.py
~$ sudo /usr/share/bcc/tools/tplist -l /usr/lib/postgresql/9.5/bin/postgres
Traceback (most recent call last):
  File "/usr/share/bcc/tools/tplist", line 16, in <module>
    from bcc import USDT
  File "/usr/lib/python2.7/dist-packages/bcc/__init__.py", line 28, in <module>
    from .libbcc import lib, _CB_TYPE, bcc_symbol
  File "/usr/lib/python2.7/dist-packages/bcc/libbcc.py", line 160, in <module>
    lib.bcc_usdt_get_probe_argctype.restype = ct.c_char_p
  File "/usr/lib/python2.7/ctypes/__init__.py", line 378, in __getattr__
    func = self.__getitem__(name)
  File "/usr/lib/python2.7/ctypes/__init__.py", line 383, in __getitem__
    func = self._FuncPtr((name_or_ordinal, self))
AttributeError: /usr/lib/x86_64-linux-gnu/libbcc.so.0: undefined symbol: bcc_usdt_get_probe_argctype
```

One more error. This time in `libbcc`. Seems like another package to pull from nightly.

```
~$ sudo apt-get install libbcc
Reading package lists... Done
Building dependency tree
Reading state information... Done
The following packages will be upgraded:
  libbcc
1 upgraded, 0 newly installed, 0 to remove and 30 not upgraded.
Need to get 9,505 kB of archives.
After this operation, 0 B of additional disk space will be used.
Get:1 https://repo.iovisor.org/apt/trusty/ trusty-nightly/main libbcc amd64 0.2.0-22.git.12a09dc [9,505 kB]
Fetched 9,505 kB in 2s (3,276 kB/s)
(Reading database ... 91427 files and directories currently installed.)
Preparing to unpack .../libbcc_0.2.0-22.git.12a09dc_amd64.deb ...
Unpacking libbcc (0.2.0-22.git.12a09dc) over (0.2.0-1) ...
Setting up libbcc (0.2.0-22.git.12a09dc) ...
Processing triggers for libc-bin (2.19-0ubuntu6.9) ...
~$ sudo /usr/share/bcc/tools/tplist -l /usr/lib/postgresql/9.5/bin/postgres
~$
```

OK! No errors. This is good, as it answers my questions as to if this postgres
package was compiled with the `--enable-dtrace`. I can further confirm with
`readelf -n`

```
~$ readelf -n /usr/lib/postgresql/9.5/bin/postgres

Displaying notes found at file offset 0x00000254 with length 0x00000020:
  Owner                 Data size       Description
  GNU                  0x00000010       NT_GNU_ABI_TAG (ABI version tag)
    OS: Linux, ABI: 2.6.24

Displaying notes found at file offset 0x00000274 with length 0x00000024:
  Owner                 Data size       Description
  GNU                  0x00000014       NT_GNU_BUILD_ID (unique build ID bitstring)
    Build ID: 6990037682e6668adc87ae7a6b82e4640959cf52
```

There are no USDT or bpf traces found here, so next step is to recompile
postgres with `--enable-dtrace` and see what probes are available to use with
BPF (spoiler: [there are a lot of them](https://www.postgresql.org/docs/current/static/dynamic-trace.html)).

