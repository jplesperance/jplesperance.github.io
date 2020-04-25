---
title: Attacking Wifi Series, Part 6<br />Hacking WPA/WPA2 PSK With Aircrack-ng
layout: post
categories: [Attacking Wifi, Hacking, Pen Testing, Wireless, Aircrack-ng, WPA, WPA2]
---



### Overview

Unlike open authentication, shared key authentication requires more than just knowledge of the SSID, the same secret key must by known by the client and access point.

For this scenario, we will be using the information below to illustrate how to conduct the attack and attain the WEP key.  

**Target Information**
* **BSSID**: 34:08:04:09:3D:38
* **AP Channel**: 3
* **ESSID**: hitme (WPA2 PSK)
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

### Deauthentication Attack

Since the AUTH column is blank, we conduct a [fake authentication attack](https://lesperance.io/attacking-wifi-commands#fake-authentication) in order to be able to communicate with the AP.  

> root@attacker:~# **aireplay-ng -1 0 -e hitme -b 34:08:04:09:3D:38 -h 00:1F:33:F3:51:13 mon0**

If the output from the fake authentication attack specifies *AP rejects open-system authentication*, we know that the access point is configured for share key authentication.

We need to acquire a PRGA XOR file before we can conduct a successful fake authentication attack on the access point.  This file is acquired what a client connects to the network, which in a real world network environment can take a while to capture.  You really have 2 options when it comes to this:
1 Be patient and wait for a client to connect, this is you only option if there are no currently connected clients on the network
2 Run a deauthentication attack on one of the connected clients to force the client to reassociate to the network, allowing us to capture the shared key authentication handshake.

After successfully completing the capture of the handshake, airodump with now show SKA in the AUTH column for the access point

### Create Airolib Database

### Crack the WPA Key

#### Wordlist-based Crack

#### Airolib Database-based Crack