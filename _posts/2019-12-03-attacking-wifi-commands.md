---
title: Attacking Wifi Series, Part 1<br /> Overview & Commands
categories: [Attacking Wifi, Hacking, Pen Testing, Wireless, Aircrack-ng, WEP, WPA, WPA2, Pyrit, CoWPAtty, Rainbow Tables]
layout: post
---
Welcome to the Attacking Wifi Series.  This series of blog posts will cover different scenarios around Pentesting and Hacking Wifi.  

This post will highlight many of the different aircrack-ng commands used in hacking/pen testing wireless networks.  This post does not go into the how, but is more of a reference of the commands and parameters.

## Table of Contents
* [Posts in this series](#posts-in-this-series)
* [General](#general)
  * [Monitor Mode](#monitor-mode)
  * [Scanning Networks](#scanning-networks)
  * [Deauthentication Attack](#deauthentication-attack)
* [Cracking](#cracking)
  * [IV-based Crack](#iv-based-crack)
  * [PTW Crack](#ptw-based-crack)
  * [Word List Crack](#word-list-based-crack)
  * [Airolib DB Crack](#airolib-db-crack)
  * [JTR-based Crack](#jtr-based-crack)
* [WEP Attacks](#wep-attacks)
  * [Fake Authentication](#fake-authentication)
  * [ARP Request Replay Attack](#arp-request-replay-attack)
  * [Interactive Packet Replay Attack](#interactive-packet-replay-attack)
  * [KoreK ChopChop Attack](#korek-chopchop-attack)
  * [Fragmentation Attack](#fragmentation-attack)
  * [Craft ARP Request Packet](#craft-arp-request-packet)
  * [Inject Packet](#inject-packet)
  * [Fake Shared Key Authentication](#fake-shared-key-authentication) 
* [WPA Attacks](#wpa-attacks)
  * [coWPAtty Attack](#cowpatty-attack)
  * [Pyrit Sniff](#pyrit-sniff)
  * [Pyrit Dictionary Crack](&pyrit-crack-dictionary)
  * [Pyrit Database Crack](#pyrit-crack-database)
 
## Posts in this Series

Since this series will be covering several Wifi hacking scenarios, I have decided to make each scenario its own post.  Each post will walk you through the attack.  Infomation is provided to allow you to setup each scenario in your own wifi lab so that you can actually practice the attack.  If you don't have a space AP to use for this, check out [Rasperry Pi as an Wifi AP](https://lesperance.io/rpi-wifi-ap) on how to create a wifi ap on a raspberry pi for the purpose of practicing hacking wifi.

Below is a list of posts for this series.

* *Overview & Commands* <-- This post
* [Hacking WEP with Connected Clients](https://lesperance.io/hacking-wep-connected-clients) - Posted 3/18/20
* [Hacking WEP via a Client](https://lesperance.io/hacking-wep-via-client) - Posted 4/23/20
* [Hacking Clientless WEP Networks](https://lesperance.io/hacking-clientless-wep) - Posted 4/25/20
* [Bypassing WEP Shared Key Authentication]() - Posted 4/27/20
* [Hacking WPA/WPA2 PSK]() - Posted 4/29/20
* [Cracking WPA with JTR and Aircrack-ng]() - Posted 5/1/20
* [Cracking WPA with coWPAtty]() - Posted 5/5/20
* [Cracking WPA with Pyrit]() - Posted 5/10/20
* [Wireless Recon]() - Posted 5/15/20
* [Rogue Access Points]() - Posted 5/20/20
* [Honeypots]() - Posted 5/25/20

## General

### Monitor Mode
There are a couple different options for putting your wifi adapter into monitor mode.

> `iw dev <interface> set monitor none`

> `airmon-ng start <interface>`

### Scanning Networks
Airodump-ng is used to scan for wifi networks and clients that are in the range of your wireless card

> `airodump-ng -c <channel> -w <capture> --wps --band abg --essid <essid> --bssid <bssid> <int>`

The required parameters
* `<int>` The wireless interface that is in monitor mode

The following flags are all optional
* `-c <channel>` This will filter your scan to a specific wifi channel
* `--wps` This flag will include WPS information for wireless networks found
* `-w <capture>` This flag will write the scan results to a file
* `--band <bands>` This flag allows you to only scan wifi networks operating on specified bands
* `--essid <essid>` This flag will filter the scan to a specific Client
* `--bssid <bssid>` This flag will filter the scan to a specific AP

### Deauthentication Attack
This attacks sends disassociate packets to one or more clients connected to a specific AP
> `aireplay-ng -0 <num> -a <ap> -c <client> <int>`

All parameters and flags are required
* `-0` Deauthentication attack method
* `<num>` The number of deauths to send, 0 will send continuously
* `-a <ap>` The mac address of the AP
* `-c <client>` The mac address of the client to deauthenticate
* `<int>` The wireless interface to use

## Cracking

The following are various methods that can be used to crack the authentication of wireless networks.

### IV-based Crack

The following is a method of IV-based cracking.  This is aircrack-ng's default
methed of cracking when no flags are provided.  This method only works for WEP,
not WPA/WPA2/WPA3. 
> `aircrack-ng <capture>`

### PTW-based Crack

The PTW attack is both the newest and most powerful WEP attack.  It only
require 20,000 to 40,000 packets to be successful, though in some cases as many
as 70,000 packets could be needed for a successful attack.
> `aircrack-ng -z <capture>`

* `-z` Invokes WEP PTW Attack mode

### Word List-based Crack

This method works for both WEP and WPA-PSK cracking.
> `aircrack-ng -w <wordlist> <capture>`

* `-w <wordlist>` The wordlist to use to try and crack WEP/WPA-PSK

If the capture file does not contain the APs SSID, you will have to use the following command to specify the extra information aircrack needs for generating the PMKs

> `aircrack-ng -w <wordlist> -e <essid> -b <bssid> <capture>`

* `-e <essid>` The SSID of the AP
* `-b <bssid>` The mac address of the AP

### Airolib DB Crack

Airolib-ng is a tool for managing and storing ESSIDs and password lists, compute their Pairwise Master Keys, and use them to crack WPA and WPA2 passwords.
> `aircrack-ng -r <dbName> <capture>`

* `-r <dbName> - The name of the airolib-ng database`

### JTR-based Crack

This method uses John the Ripper and a wordlist while applying word mangling rules to attempt to crack a WPA/WPA2 Password
> `john --wordlist=<wordlist> --rules --stdout | aircrack-ng -e <essid> -w - <capture>`

* `--wordlist=<wordlist> - The word list to use`
* `--rules - apply word mangling rules`

## WEP Attacks

### Fake Authentication

The fake authentication attack allows you to associate to an access point using either of the two types of WEP authentication: the open system and shared key authentication.  

This attack is useful in scenarios where there are no associated clients and you need to fake an authentication to the AP.
> `aireplay-ng -1 0 -e <essid> -a <ap> -h <you> <interface>`

* `-1 - Fake Authentication Attack`
* `0 - The reassociation timing in seconds`
* `-e <essid> - The wireless network name (ESSID)`
* `-a <ap> - The AP MAC address`
* `-h <you> - Your attacking MAC address`


### ARP Request Replay Attack

The ARP request replay attack is the most effective way to generate new initialization vectors and of all the attacks Aireplay has to offer, this attack is probably the most reliable.

> `aireplay-ng -3 -b <ap> -h <you> <interface>`

* `-3 - ARP Request Replay Attack`
* `-b <ap> - The AP MAC address`
* `-h <you> - Your attacking MAC address`

For this attack, your wireless card needs to be in monitor mode and you will need either the MAC address of an associated client or your own MAC address after having performed a fake authentication with the AP.

### Interactive Packet Replay Attack

The Interactive Packet Replay attack allows you to choose a specific packet for replaying/injecting against the target network.
> `aireplay-ng -2 -b <ap> -d ff:ff:ff:ff:ff:ff -f 1 -m 68 -n 86 <interface>`

* `-2 - Interactive Packet Replay Attack`
* `-b <ap> - The AP MAC address`
* `-d ff:ff:ff:ff:ff:ff - Select packets with a broadcast destination address`
* `-t 1 - Select packets with the "To Distribution System" flag set`
* `-m <num> - Minimum packet size`
* `-n <num> - Maximum packet size`

### KoreK chopchop attack

The Korek chopchop attack, when successful, can decrypt a WEP data packet without knowing the WEP key and can even work against dynamic WEP.  

This attack does not recover the WEP key itself; it merely reveals the plaintext of the packets.

> `aireplay-ng -4 -b <ap> -h <you> <interface>`

* `-4 - KoreK ChopChop Attack`
* `-b <ap> - The AP MAC address`
* `-h <you> - The source MAC address

### Fragmentaion Attack

This attack works by obtaining a small amount of the keying material from the packet and then attempts to send ARP and/or LLC packets with known content to the AP.  If the packet is successfully echoed back by the AP, then a larger amount of the keying information can be obtained from the returned packet.  This process is repeated until 1500 bytes of the PRGA are obtained.
> `aireplay-ng -5 -b <ap> -h <you> <interface>`

* `-5 - The Fragmentation Attack`
* `-b <ap> - The AP MAC address`
* `-h <you> - Source MAC address`

### Craft ARP Request Packet**

Packetforge-ng is used to create encrypted packets that can later be used for injection.  You can create various types of packets such as UDP and ICMP packets although it is most commonly used to create ARP requests for subsequent injection.
> `packetforge-ng -0 -a <ap> -h <you> -l <sourceIP> -k <destIP> -y <xorFile> -w <out>`

* `-0 - Generate an ARP request packet`
* `-a <ap> - The AP MAC Address`
* `-h <you> - The source MAC address`
* `-k <distIP> - The destination IP`
* `-l <sourceIP> - The source IP`
* `-y <xorFile> - The PRGA filename`
* `-w - The filename to save the packet to`

### Inject Packet/Interactive Packet Replay

This attack uses a crafted ARP request packet and injects it to capture enough IVs to subsequently crack the WEP key on the AP

> `aireplay-ng -2 -r <packet> <interface>`

* `-2 - Interactive Packet Replay Attack`
* `-r <packet> - Filename of the crafted ARP packet`

### Fake Shared Key Authentication

This attack is used for bypassing WEP Share Key Authentication.  It uses a captured keystream file and conducts a fake authentication.

> `aireplay -1 -0 -e <essid> -y <captureFile> -a <ap> -h <you> <interface>`

* `-1 - Fake Authentication Attack`
* `0 - Reassociation timing in seconds`
* `-e <essid> - The wireless network name(SSID)`
* `-y <captureFile> - Filename of the captured keystream`
* `-a <ap> - The AP MAC address`
* `-h <you> - Source MAC address`

## WPA Attacks

### coWPAtty Attack 

#### Dictionary Mode

coWPAtty is a versatile tool that can recover WPA pre-shared keys, from a captured handshake, using either dictionary or rainbow table attacks.

> `cowpatty -r <capture> -f <wordlist> -2 -s <essid>`

* `-r <capture>` - The capture filename
* `-f <wordlist>` - The wordlist to use
* `-2` - Use non-strict mode as coWPAtty has an issue with airodump-ng captures
* `-s <essid> - The network ESSID

#### Rainbow Table Mode

Generate the hashes for our ESSID along with a dictionary file containing password

> `genpmk -f <wordlist> -d <hashesFilename> -s <essid>`

* `-f <wordlist>` - The path to the dictionary file
* `-d <hashesFilename>` - The filename to save the computed hashes to
* `-s <essid>` - The network ESSID

Run coWPAtty using the generated hashes

> `cowpatty -r <capture> -d <hashesFilename> -2 -s <essid>`

* `-r <capture>` - The capture filename
* `-d <hashesFilename>` - The file name of the computed hashes to use
* `-2` - Use non-strict mode as coWPAtty has an issue with airodump-ng captures
* `-s <essid>` - The network ESSID

### Pyrit Sniff

Pyrit, like airolib-ng and coWPAtty, uses a pre-computed database of WPA pre-shared key tables, though with the distinct advantage of being able to leverage GPUs to accelerate the generation of PMK tables.

> `pyrit -r <interface> -o <capture> stripLive`

* `-r <interface>` - The wireless interface to use
* `-o <capture>` - The file to save the captured data to
* `striplive` - Only saves the WPA handshakes

### Validate the 4-way handshake

Pyrit is able to analyze the capture file and determine if the capture contains any valid handshakes

> `pyrit -r <capture> analyze`

* `-r <capture>` - The capture file

### Pyrit Crack Dictionary

Launching pyrit using a basic dictionary attack

> `pyrit -r <capture> -i <wordlist> -b <ap> attack_passthrough`

* `-r <capture>` - The capture file
* `-i <wordlist>` - The wordlist file to use
* `-b <ap>` - The *OPTIONAL* BSSID of the target AP
* `attack_passthrough` - Attempt to crack the WPA password using the wordlist

### Pyrit Crack Database

#### Import Wordlist into Database

> `pyrit -i <wordlist> import_passwords`

* `-i <wordlist>`- The wordlist to use
* `import_passwords` - Import the passwords into the database

#### Add the ESSID of the Access Point

> `pyrit -e <essid> create_essid`

* `-e <essid>` - The network ESSID
* `create_essid` - Import the network ESSID

#### Compute the PMKs

> `pyrit batch`

#### Launch Pyrit in database mode

> `pyrit -r <capture> -b <ap> attack_db`

* `-r <capture>` - The capture file
* `-b <ap>` - The AP's MAC address
