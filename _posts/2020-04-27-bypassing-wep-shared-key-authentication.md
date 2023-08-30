---
title: Bypassing WEP Shared Key Authentication
layout: post
category: attacking wifi series
author: jesse
thumbnail: /assets/img/evil-wifi.png
date: 2020-04-27T00:00:00:01.613Z
summary: In this post, we will focus on attacking an access point that utilizes shared-key authentication 
keywords: access wifi attacking security wep bypass authentication
permalink: /blog/bypass-wep-shared-key-auth/
---

Up to this point, our attacks have been focused on WEP access points that were configured with open authentication.

Now, we will focus on a WEP access point using a shared key for authentication.

### Overview

Unlike open authentication, shared key authentication requires more than just knowledge of the SSID, the same secret key must by known by the client and access point.

For this scenario, we will be using the information below to illustrate how to conduct the attack and attain the WEP key.  

**Target Information**
* **BSSID**: 34:08:04:09:3D:38
* **AP Channel**: 3
* **ESSID**: hitme (Shared Key Authentication)
* **Client**: 00:18:4D:1D:A8:1F
* **mon0**: 00:1F:33:F3:51:13

### Initial Attack Setup

The first step in every attack scenario is to place the wireless interface in [monitor mode](https://lesperance.io/attacking-wifi-commands#monitor-mode) on the same channel as the access point.

> root@attacker:~# **airmon-ng start wlan0 3**

This will set **wlan0** into monitor mode as **mon0** on channel 3

### Recon

Now, an [Airodump sniffing session](https://lesperance.io/attacking-wifi-commands#scanning-networks) needs to be started and write the capture file to the disk for usage by Aircrack-ng for breaking the WEP key

> root@attacker:~# **airodump-ng -c 3 --bssid 34:08:04:09:3D:38 -w wep1 mon0**

This will start airodump-ng, listening on Channel 3 and filtering on the BSSID and saving the output to *wep1*

Despite have shared key authentication configured on the access point, the AUTH column in airodump will not display SKA until a wireless client authenticates to the network.

### Authenticate

Since the AUTH column is blank, we conduct a [fake authentication attack](https://lesperance.io/attacking-wifi-commands#fake-authentication) in order to be able to communicate with the AP.  

> root@attacker:~# **aireplay-ng -1 0 -e hitme -b 34:08:04:09:3D:38 -h 00:1F:33:F3:51:13 mon0**

If the output from the fake authentication attack specifies *AP rejects open-system authentication*, we know that the access point is configured for share key authentication.

We need to acquire a PRGA XOR file before we can conduct a successful fake authentication attack on the access point.  This file is acquired what a client connects to the network, which in a real world network environment can take a while to capture.  You really have 2 options when it comes to this:
1 Be patient and wait for a client to connect, this is you only option if there are no currently connected clients on the network
2 Run a deauthentication attack on one of the connected clients to force the client to reassociate to the network, allowing us to capture the shared key authentication handshake.

After successfully completing the capture of the handshake, airodump with now show SKA in the AUTH column for the access point

### Deauthentication Attack

Since it is both faster and easy to deauthenticate a client, we will use that route in this scenario.

> root@attacker:~# **aireplay-ng -0 1 -a 34:08:04:09:3D:38 -c 00:18:4D:1D:A8:1F mon0**

After, the client reconnects to the network and airodump will display that is has captured the keystream.

### Shared Key Fake Authentication Attack

Now that we have the PRGA XOR file for the network, we can now conduct the shared key fake authentication attack, which is largely the same as the normal fake authentication attack.

> root@attacker:~# **aireplay-ng -1 0 -e hitme -y wep1-34-08-04-09-3D-38.xor -a 34:08:04:09:3D:38 -h 00:1F:33:F3:51:13 mon0**

The output from the attack should show that is was successful, which we can verify by checking that airodump shows our mac address as being associated with the access point.

### ARP Request Replay Attack

Now that we have gotten past the hurdle of shared key authentication on the access point, we can attack the access point as we did in the [Hacking WEP With Connected Clients](https://lesperance.io/hacking-wep-connected-clients) scenario.  In this case, we will use the ARP request replay attack due to its extreme reliability.

> root@attacker:~# **aireplay-ng -3 -b 34:08:04:09:3D:38 -h 00:1F:33:F3:51:13 mon0**

Now, aireplay is waiting for an ARP packet to appear on the network.  

### Deauthentication Attack

We can expedite this process by deauthenticating a connected wireless client.  Upon reconnection, it is highly likely the client will send an ARP packet.

> root@attacker:~# **aireplay-ng -0 1 -a 34:08:04:09:3D:38 -c 00:18:4D:1D:A8:1F mon0**

Watching our ARP request replay attack, as soon as the client reconnects to the network, it catches an ARP packet and injects it into the network.

Checking back to airodump, we can see that IVs are being captured at the rate of a couple hundred per second

### Crack the WEP Key

Now that we have captured around 30,000 IVs, we just need to run aircrack-ng against our running capture.

> root@attacker:~# **aircrack-ng wep1.cap**

Now we should be presented with the WEP key.  If however, aircrack was unable to successfully crack the key, with leaving both the airodump capture running along with aircrack, aircrack will reattempt to crack the key every 5000 new IVs captured.
