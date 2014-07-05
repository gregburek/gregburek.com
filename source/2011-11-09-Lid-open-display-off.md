---
title: Lid Open, Display Off
---

It has been more than a year since my [last
post](http://blog.gregburek.com/2010/10/21/macbook-lcd-trick.html) and that
computer has been retired. However, I still find it useful to run my new
MacBook Air attached to an external monitor and with its internal display
disabled. A few days ago, I found a better and more permanent solution than a
flimsy magnet: 

1. Attach the closed MacBook to an external display
2. Wake the MacBook with an external input device, like usb or bluetooth
   keyboard. 
3. Open the lid of the MacBook and the internal display will remain off

That's it. No magnets required. 

It takes a little bit more for this to work under OS X 10.7 Lion,
though. Entering the following command in terminal seems to do the
trick:

``` shell
sudo nvram boot-args="iog=0x0"
````

Undoing this is as simple as typing the following, also in terminal:

``` shell
sudo nvram -d boot-args 
````

You can also zap the PRAM (press Cmd+Opt+p+r at power up) to restore it
to the new Lion behaviour. 

This works great and I've been using it to improve my laptop's ventilation and
wireless reception.


I first saw this documented here: [Mac OS X Hints - 10.7: Disable internal
laptop display when external display is
attached](http://hints.macworld.com/article.php?story=20110901113922148)


