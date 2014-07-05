---
title: iTunes library at home accessible over SSH tunneled AFP
---

Today I freed 150GB of space from my Macbook by moving my music to my Mac Mini
that sits below my TV, at home, behind two firewalls.  

First, I [hardened SSH][1] on the mini and setup my laptop to log in without a
password, but I didn't go through the SSHFS stuff, as I like AFP better (for
the moment).  Now, I can access my Mini by running:

``` shell
LAPTOP$ ssh -f -N -p PORT USER@OUTSIDEIP -L 1202:localhost:5900 -L 1203:localhost:548
````

Where PORT is the random port I choose when [hardening SSH][1], USER is the
username on my mini and OUTSIDEIP is the external IP of my cable modem.  Then,
I can exit from Terminal on my laptop, press command-K and run:

``` shell
afp://localhost:1203
````

and get the list of shared folders.  Or I can run:

``` shell
vnc://localhost:1202
````

and get Screen Sharing with the Mini behind all those firewalls.  

Finally, I [moved my iTunes Library to an external harddrive][2] and hooked up
that beast to the Mini.  By SSHing into my Mini and then running the AFP
command, I can now access my very large iTunes library from anywhere with an
internet connection.  

If I would like to end the SSH tunnel, I run:

``` shell
ps auxww | grep -i ssh
````

After finding the ID of the process I do: 

``` shell
kill -9 SSH_PID
````

with the SSH ID.  

I will use some applescript to make this "connect, mount, launch iTunes" dance
a little bit more simple, but I think this is progress, as it has breathed new
life into my 2.5 year-old laptop.  

[1]: http://tinyapps.org/docs/ssh_osx_and_sshfs.txt "Hardening SSH and Mounting Remote Filesystem in OS X Finder via SSHFS"
[2]: http://lifehacker.com/5261172/move-your-itunes-library-to-an-external-hard-drive "Move Your iTunes Library to an External Hard Drive"

