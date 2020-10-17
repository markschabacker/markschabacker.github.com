---
layout: post
title: "Static DHCP Reservations for Unifi Devices"
---

I switched my home network over to [Unifi](https://unifi-network.ui.com/) gear a few years back and have been thoroughly impressed.  In my experience, it's fast, reliable, and fairly inexpensive.  However, some of the user interface can be a little less than intuitive.  I hit the following friction point every time I add a new piece of Unifi gear to the network.

## Creating DHCP Reservations for Unifi Gear

I like to keep my networking infrastructure in a loosely organized IP topology.  Rather than hard-coding static addresses on the specific devices, I prefer to create DHCP reservations.  You would think this would be easy, but for some unfathomable reason, the Unifi controller hides the ability to set DHCP-assigned IPs for Unifi specific gear.  It's important to note that these steps are not necessary for regular devices on your network, just for the infrastructure.

1. Find your new device's MAC
    1. Find your new device on the Devices tab in your Controller.  In this example, I'll be giving a static IP to `u6-lite-01`.

        ![Device at Auto-Assigned IP](/images/unifi-dhcp-01-problem.png)

    1. Select your new device and expand the Details tab to find your device's MAC address.  Write the MAC down somewhere.

        ![Device MAC](/images/unifi-dhcp-02-ap-mac.png)

1. Create a new Unifi "client" to hold your reservation
   1. Navigate to the Clients screen in the controller and select `+ Add Client` at the top.
   1. Add a new client with MAC + alias, click Add (don't set fixed IP yet!).

        ![Adding Client](/images/unifi-dhcp-03-capture-client.png)

1. Set your fixed IP
   1. Still on the Clients screen, select `+ All Configured Clients` on the top.
   1. Filter to your newly added alias.

        ![Client without IP](/images/unifi-dhcp-04-client-without-ip.png)

   1. Select your new device.
   1. Navigate to the Network tab and give it the fixed ip.

        ![Give the Client an IP](/images/unifi-dhcp-05-give-client-ip.png)

1. Restart your device so it grabs the new IP
   1. Find your device and restart it.
   1. Enjoy your AP at its new IP!

        ![Client at the IP](/images/unifi-dhcp-06-client-at-ip.png)
