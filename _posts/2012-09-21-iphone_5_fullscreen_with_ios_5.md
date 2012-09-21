---
layout: post
title: "Full Screen iPhone 5 Layouts with iOS 5"
---

Keeping with Apple's traditional secrecy surrounding new product launches, the average iOS developer received confirmation of the iPhone 5's new screen size at the same time as the rest of the world: Apple's September 12th media event.  New developer documentation was released soon afterward and the twittersphere was abuzz with the ```Default-568h@2x.png``` file.

<blockquote class="twitter-tweet"><p>Took me an annoying few minutes to find this: to enable the tall iPhone screen, just add a 640x1136 launch image named:Default-568h@2x.png</p>&mdash; Marco Arment (@marcoarment) <a href="https://twitter.com/marcoarment/status/246043738474967040" data-datetime="2012-09-13T00:32:53+00:00">September 13, 2012</a></blockquote>
<script src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

<blockquote class="twitter-tweet"><p>Default-568h@2x.png. You’re welcome. (Hat tip to Leeus)</p>&mdash; ericasadun (@ericasadun) <a href="https://twitter.com/ericasadun/status/246000647827255296" data-datetime="2012-09-12T21:41:39+00:00">September 12, 2012</a></blockquote>
<script src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Unfortunately, the most obvious way to add ```Default-568h@2x.png``` is by downloading Xcode 4.5 and plugging the new image into the App's Summary screen.  This inevitably upgrades the application to the iOS 6 SDK.  Normally this would not be a huge issue.  However, as revealed in the [UIKit section of the Release Notes](https://developer.apple.com/library/ios/#releasenotes/General/RN-iOSSDK-6_0/_index.html#//apple_ref/doc/uid/TP40012166-CH1-SW13), rotation has been significantly reworked in iOS 6.0.  Rotation capabilities are now handled by the topmost ViewController in the stack (typically a UINavigationController) rather than on a per-ViewController basis like they were in 5.1.  Perfectly functional 5.1 apps suddenly stop rotating or began rotating in unexpected screen configurations.  [Sketchy, swizzled ViewController](https://gist.github.com/3725118) fixes sprung up immediately.  

Needless to say, this throws a wrench in plans to update and quickly submit an iOS 6 compatible version of an app.

Something struck me as odd about the enigmatic, file-existence based gatekeeper to 4-inch fullscreen.  Perhaps the SDK version didn't even matter?  With only one way to find out, I reset my local git repo and reopened my project in Xcode 4.4.1.  I dragged my new ```Default-568h@2x.png``` into the launch-images group in the Xcode project and fired up the 4 inch simulator from Xcode 4.5.  One "Run in Simulator" later, my app was happily occupying the full screen of the iPhone 5.

### Steps ###
1. Install Xcode 4.5 and 4.4.1 side by side (I always rename my old /Applications/Xcode.app before installing a new version)
2. Create an image named ```Default-568h@2x.png```
2. Add the image to your SDK 5.1 App's project in Xcode 4.4.1
3. Launch the iPhone 5 Simulator from Xcode 4.5 (Toolbar >Xcode > Open Developer Tool > iOS Simulator)
4. Run your app with the Simulator selected in Xcode 4.4.1
    * It crashes on the first run on my box
5. Switch the simulator to a different device (Toolbar > Hardware > Pick One)
6. Switch the simulator back to "iPhone (Retina 4-inch)" 
7. Tap on your app's icon

Your app should start up in full screen.  I haven't figured out how to debug in the simulator yet.  (Update: debugging on the actual iPhone 5 works fine)

### Caveats ###
* My app's layout is relatively simple.  Mostly UITableViews with a couple custom Views and an iAd banner across the bottom.  I use a single storyboard for iPhone and iPad so it was laid out using springs and struts with multiple screen sizes in mind.  You may have a much more difficult time if your app is using hard-coded width and heights or uses a fancy layout framework.
* Everything is working fine on my actual iPhone 5 but my App submisison is still "Waiting for Review".  I'll update this post if Apple has any issues with this technique.  
* You should probably wait to test your updated code on an __actual__ iPhone 5.  I feel a little better knowing I did.
* Don't forget 4 inch screenshots in your App Store submissions.
