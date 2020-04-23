---
title: Attacking Wifi Series, Part 4<br /> Hacking Clientess WEP Networks
layout: post
categories: [Attacking Wifi, Hacking, Pen Testing, Wireless, Aircrack-ng, WEP]
---

In the last couple of posts, we have covered hacking WEP networks that have connected clients.  What happens if there are no connected clients on the wireless network to help generate our ARP request?  There are 2 attack methods that are usable in this scenario, KoreK chopchop and the fragmentation attack.

### Overview

There are times where you will find yourself in a place where the WEP wireless network you are pentesting/hacking has no connected clients.  This limits our ability to generate ARP packets on the network.  However, there are 2 attacks in the aircrack-ng arsenal that can help us in this situation, KoreK chopchop and the fragmentation attack.

For this scenario, we will be using the information below to illustrate how to conduct the attack and attain the WEP key.  There are several different methods of executing this attack.  I am only showing one of them here.  I may cover the others in a different post.

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

We conduct a [fake authentication attack](https://lesperance.io/attacking-wifi-commands#fake-authentication) in order to be able to communicate with the AP.  Unlike in the previous posts, we will set a reassociation timer so that is doesn't time out

> root@attacker:~# **aireplay-ng -1 6000 -e hitme -b 34:08:04:09:3D:38 -h 00:1F:33:F3:51:13 mon0**

This allows us to associate with the access point and keeps our session alive.

### Fragmentation Attack

The first of the 2 methods of attack we will be using is the [Fragmentation Attack](https://lesperance.io/attacking-wifi-commands#fragmentation-attack).  I have personally had more success using this method than I have with using the KoreK chopchop attack.

The Fragmentation Attack will help us attain the PRGA file.  While this file is not the WEP key, it can be used to craft a packet that can be used in various injection attacks.  The Fragmentation Attack requires at least one data packet to be received from the AP before an attack can be initiated.


> root@attacker:~# **aireplay-ng -5 -b 34:08:04:09:3D:38 -h 00:1F:33:F3:51:13 mon0**

Once the attack is launched, Aireplay starts to listen for a packet that can be used and when it finds a candidate, you will be prompted about using the packet in the attack.  

### Crafting a Packet with the PRGA

Now that we have the PRGA file for the network, we can use packetforge-ng to craft an ARP Request Packet.

> root@attacker:~# **packetforge-ng -0 -a 34:08:04:09:3D:38 -h 00:1F:33:F3:51:13 -k 255.255.255.255 -l 255.255.255.255 -y crafted-packet -w 

One note on selecting the source and destination IP addresses, many APs will respond properly if you use 255.255.255.255 for both.

### KoreK ChopChop Attack

Now, let's look at the KoreK ChopChop Attack.  When successful, it can decrypt WEP data packets without knowing the WEP key.  Additionally, it can even work against dynamic WEP.

Not all APs are vulnerable to the KoreK ChopChop Attack.  Some APs will drop packets shorter the 60 bytes.

> root@attacker:~# **aireplay-ng -4 -b 34:08:04:09:3D:38 -h 00:1F:33:F3:51:13 mon0**

Similar to the Fragmentation Attack, after launching the chopchop attack, you will be prompted to select the packet for the attack.  Additionally, the keystream will be saved into a XOR file that can be used to create a packet with packetforge-ng, using the packetforge command above.

### Interactive Packet Replay

Now we can take our ARP request packet that we crafted and inject it into the network with the Interactive Packet Replay to generate the IVs needed for cracking the WEP key.

> root@attacker:~# **aireplay-ng -2 -r crafted-packet mon0**

When promted to use the crafted packet, enter **y** to start the injection.

If you check airodump, you should see the number of packets between your client and the AP should be constantly increasing.

### Crack the WEP Key

Now, we just need to run aircrack-ng against our running capture.

> root@attacker:~# **aircrack-ng wep1.cap**

Now we should be presented with the WEP key.
