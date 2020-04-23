---
title: Attacking Wifi Series - Cracking WEP With Connected Clients
layout: post
categories: [Attacking Wifi, Hacking, Pen Testing, Wireless, Aircrack-ng, WEP]
---

This post will build off of the [Attacking Wifi - Commands](https://lesperance.io/attacking-wifi-commands) post.  In this post, we will look at how to use different Wifi attack commands to crack the key of a WEP AP with at least 1 connected client.

### Overview

Most technically savvy individuals know that WEP encryption is a serious no-no, though for various compatibility reasons, many corporate environments are still using WEP encryption in their wireless networks. 

** Target Information **
* **BSSID**: 34:08:04:09:3D:38
* **AP Channel**: 3
* **ESSID**: hitme (Open Authentication)
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

### Authenticate

Now, we conduct a [fake authentication attack](https://lesperance.io/attacking-wifi-commands#fake-authentication) against the AP

> root@attacker:~# **aireplay-ng -1 0 -e hitme -a 34:08:04:09:3D:38 -h 00:1F:33:F3:51:13 mon0**

This allows us to associate with the access point.

### Generating Weak IVs

Now we can launch the [ARP Request Replay Attack](https://lesperance.io/attacking-wifi-commands#arp-request-replay-attack)

> root@attacker:~# **aireplay-ng -3 -b 34:08:04:09:3D:38 -h 00:1F:33:F3:51:13 mon0**

You may have to wait a bit until an ARP request shows up on the network, this will depend on the amount of traffic on the network.  You will see the *Data* field in the airodump session rapidly increasing as the weak IVs are being captured.

To help with this, we can use the [Deauthentication Attack](https://lesperance.io/attacking-wifi-commands#deauthentication-attack)

> root@attacker:~# **aireplay-ng -0 1 -a 34:08:04:09:3D:38 -c 00:18:4D:1D:A8:1F mon0**

This will deauthenticate the client from the AP, forcing the client to send ARP packets to the AP as it reconnects, which we will need to replay to help force the AP to generate a large number of weak IVs.

### Cracking the WEP Key

Once we have captured a substantial number of weak IVs, 250,000 for 64-bit keys and 1.5 million for 128-bit keys, we can now use aircrack-ng to crack the key.  For this we have 2 options.

The first method, is the default [IV-based cracking](https://lesperance.io/attacking-wifi-commands#iv-based-crack) method.

> root@attacker:~# **aircrack-ng wep1.pcap**

The other option, which typically is a faster option, is the [PTW Crack](https://lesperance.io/attaking-wifi-commands#ptw-based-crack) method.  It should be noted, this method only works with ARP request/reply packets.

> root@attacker:~# **aircrack-ng -z wep1.pcap**

The result of either of these commands should result in the WEP Key




