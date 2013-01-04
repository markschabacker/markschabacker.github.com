---
layout: post
title: "agvtool with New Projects"
---

I use Apple's wonderful [agvtool](https://developer.apple.com/library/mac/#documentation/Darwin/Reference/ManPages/man8/agvtool.8.html) for Xcode project versioning in practically every personal or work project.  It can't be beat for easy versioning.  For some unexplained reason, new Xcode projects are not initialized with the necessary settings to use agvtool right out of the box.  This annoyance inevitably bites me at the worst time possible: the first [TestFlight](https://testflightapp.com/) deployment for a new app.  

<pre>
[me@mybox ShinyNewApp(master)]$ agvtool bump -all
There does not seem to be a CURRENT_PROJECT_VERSION key set for this project.  Add this key to your target's expert build settings.
[me@mybox ShinyNewApp(master)]$ # begin furious googling for CURRENT_PROJECT_VERSION
</pre>

Fortunately, this is an easy fix.

1. Open your project in Xcode
2. Navigate to your project in Xcode's __Project Navigator__ (⌘1)
3. Navigate to the __Build Settings__ tab and find the __Current Project Version__ entry
4. Set the __Current Project Version__ to 0 (or 1 less than your preferred starting build number)
![Setting Current Project Version in Xcode](/images/current_project_version.png)
5. Now you're ready to use __agvtool__

<pre>
[me@mybox ShinyNewApp(master)]$ agvtool bump -all                               
Setting version of project ShinyNewApp to: 
    1.

Also setting CFBundleVersion key (assuming it exists)

Updating CFBundleVersion in Info.plist(s)...

Updated CFBundleVersion in "ShinyNewApp.xcodeproj/../ShinyNewApp/ShinyNewApp-Info.plist" to 1
Updated CFBundleVersion in "ShinyNewApp.xcodeproj/../ShinyNewAppTests/ShinyNewAppTests-Info.plist" to 1
</pre>

