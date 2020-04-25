---
title: Attacking Wifi Series, Part 3<br /> Hacking WEP via a Client
layout: post
categories: [Attacking Wifi, Hacking, Pen Testing, Wireless, Aircrack-ng, WEP]
---

In this post we will discuss how to attack a client to force it to generate new IVs rather than the access point.

### Overview

While it is true that most of the time, hacking a WEP network is accomplished by attacking the access point by generating a packet, that then would be replayed in an effort to get the access point to generate new packets with new IVs.  

However, there are some reasons for attacking the client instead of the AP.  

* Some access points max out at 130,000 unique IVs
* Some access points enforce client-to-client controls
* MAC Address whitelisting/restrictions
* Some newer access points can eliminate weak IVs
* You are unable to successfully fake auth the access point
* You are out of range for the access point, but are in range of a client

For this scenario, we will be using the information below to illustrate how to conduct the attack and attain the WEP key.  There are several different methods of executing this attack.  We are only showing one of those methods here, though, we may cover the other methods in a later post.

**Target Information**
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

Now, while is isn't required for this attack, we will conduct a fake authentication attack against the AP for 2 reasons.  First, always a good practice to conduct a fake authetication attack against a WEP AP.  Second, having you MAC associated with the access point can make this attack more reliable.

We conduct a [fake authentication attack](https://lesperance.io/attacking-wifi-commands#fake-authentication) against the AP

> root@attacker:~# **aireplay-ng -1 0 -e hitme -a 34:08:04:09:3D:38 -h 00:1F:33:F3:51:13 mon0**

This allows us to associate with the access point.

### Generating Weak IVs

Now we can launch the [Interactive Packet Replay Attack](https://lesperance.io/attacking-wifi-commands#interactive-packet-replay-attack).  THis attack allows us to choose a specific packet for replaying/injecting against our target network.  To achieve our goal, a packet that will be "naturally" successful in generating new initialization vectors must be selected.

In this scenario, we are going to attempt to use the natural packet selection method of attack.  We are going to capture packets that are within a desired size range and that have the *fromDS* flag set.

> root@attacker:~# **aireplay-ng -2 -b 34:08:04:09:3D:38 -d FF:FF:FF:FF:FF:FF -f 1 -m 68 -n 86 mon0**

### Cracking the WEP Key

Once we have captured a substantial number of weak IVs, 250,000 for 64-bit keys and 1.5 million for 128-bit keys, we can now use aircrack-ng to crack the key.  For this we have 2 options.

We are going to use the [PTW Crack](https://lesperance.io/attaking-wifi-commands#ptw-based-crack) method.  It should be noted, this method only works with ARP request/reply packets.

> root@attacker:~# **aircrack-ng -z wep1.pcap**

This should result in displaying the network's WEP key.




