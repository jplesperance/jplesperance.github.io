---
title: Attacking Wifi - WEP Scenarios
layout: post
categories: [Hacking, Pen Testing, Wireless, Aircrack-ng]
---

This post will build off of the [Attacking Wifi - Commands](https://lesperance.io/attacking-wifi-commands) post.  In this post, we will look at how to use the different commands in a series in different Wifi hacking scenarios.

## Cracking WEP with Connected Clients

Most technically savvy individuals know that WEP encryption is a serious no-no, though for various compatibility reasons, many corporate environments are still using WEP encryption in their wireless networks. 

** Target Information **
* **BSSID**: 34:08:04:09:3D:38
* **ESSID**: hitme (Open Authentication)
* **Client**: 00:18:4D:1D:A8:1F
* **mon0**: 00:1F:33:F3:51:13

### Initial Attack Setup

The first step in every attack scenario is to place the wireless interface in monitor mode on the same channel as the access point.

> root@attacker:~# **airmon-ng start wlan0 3**
> 
> Interface&nbsp;&nbsp;&nbsp;&nbsp; Chipset           Driver

This will set **wlan1** into monitor mode as **mon0**

### Recon

Now, an Airodump sniffing session needs to be started and write the capture file to the disk for usage by Aircrack-ng for breaking the WEP key

> `root@attacker:~# airodump-ng -c 3 --bssid 34:08:04:09:3D:38 -w wep1 mon0`



