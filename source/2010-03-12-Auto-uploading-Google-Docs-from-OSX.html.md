---
title: Automatically upload new files to Google Documents from OSX
date: 2010-03-12
tags: gdocs, diy, hacks, sync
---

##The Problem

I get many, many, many presentations, spreadsheets and PDFs sent
to me over email. I usually View them through Google Docs or Download them and
let the files launch in their proper programs. There are some times, however,
when I wish I could view or edit these files on my iPhone or on another
computer, usually located in our [cleanroom](http://www.nanotech.ucsb.edu/).
[Dropbox](http://www.dropbox.com/) is an incredible service for this, with an
[iPhone app](https://www.dropbox.com/iphoneapp) and multi-platform support, but
those fab computers are locked down hard and I can't edit things in the iPhone
app.

##The Caveat

Since I use Gmail for everything, I could just view the file
through the web interface on my iPhone or another computer and import things to
Google Documents with a click.

I recommend this way. I really do. Mostly because my solution is a folder
action applescript with your gmail password in plain text. This is stupid.
Very stupid. Beyond moronic. I would like to get Keychain Access from the
applescript for a better password handling, but a few hours of fiddling yielded
nothing and further thought showed it to be even more insecure to have
scriptable readouts of passwords globally enabled.

So, for the record, this is my hacked together solution.

##The Solution

1. Download [google-docs-upload](http://code.google.com/p/google-docs-upload/) and put it
somewhere. I used /Users/USERNAME/Library/Scripts/GoogleDocs/

2. Open Script Editor.app and it should pop up with an Untitled and blank
script window. Copy this into the window:

```applescript
on adding folder items to this_folder after receiving added_items
  repeat with aFile in added_items
    do shell script "java -jar /SOMEWHERE/google-docs-upload-1.3.2.jar
      aFile -rf Downloads --skip-all -u YOURUSERNAME -p
      YOURPASSWORD >> /SOMEWHERE/GDocs-upload-log.txt"
  end repeat
end adding folder items to
````

3. Replace SOMEWHERE with the path to google-docs-upload, USERNAME with your
OSX username, YOURUSERNAME with your Google username and YOURPASSWORD with your
google password. This script will run when a file is placed in the folder.
Each file is passed to google-docs-upload along with your username and password
and it decides whether it can upload the file. Any output goes to that log
file tacked on the end.

4. Save this script under ./Library/Scripts/Folder\ Action\
Scripts/UploadGDocs.scpt

5. Right click on your Downloads folder and hover over "More" until it expands.
Go and click on "Configure Folder Actions..."

6. Make sure the "Enable Folder Actions" check box is ticked, then click on the
left "+" sign, select the Downloads folder and click the Open button. Then,
select UploadGDocs.scpt from the next menu to drop down and click Attach.
Close the Script Editor and the Folder Actions Setup.

That should do it. Any new file placed in your Downloads folder will be kicked
automatically to Google Docs.

PS: For some reason, whenever I tweak this script, my Downloads folder becomes
Read-Only for my user. I fix this by right clicking on my Downloads folder,
clicking on Get Info, clicking the lock icon in the new window, inputting my
password and then setting the drop-down menu next to my name to Read&Write.
If you know what is causing this, let me know.

