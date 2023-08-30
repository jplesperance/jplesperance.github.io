---
title: Hacking WPA/WPA2 PSK
layout: post
category: ['attacking wifi series','wireless pen testing']
author: jesse
thumbnail: /assets/img/evil-wifi.png
date: 2020-05-04T00:00:00:01.613Z
summary: Diving into attacking wpa/wpa2 PSKs
keywords: attacking wifi hacking wpa wpa2 psk cracking
permalink: /blog/hacking-wpa2-psk/
---

In this post we are are going to move on to cracking WPA/WPA2 Pre-shared keys using aircrack-ng.  We will show you how to use aircrack-ng by itself, with an airolib-ng database and with John the Ripper to crack WPA/WPA2 passwords

The primary difference between cracking WEP and WPA/WPA2 is that while statistical methods can be used for speeding up the cracking of WEP pre-shared keys, only brute force can be used for WPA/WPA2 PSK.

### Overview

Although WPA-encrypted networks do not suffer from the same cryptographic vulnerabilities as WEP networks, they can still sometimes be easier to crack due to users picking weak passwords.  The impact of having to use the brute force approach is a substantial impact to efficiency.  A large dictionary can to hours to days to process due to the computational intensity of brute forcing.

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

> root@attacker:~# **airodump-ng -c 3 --bssid 34:08:04:09:3D:38 -w wpa-psk mon0**

This will start airodump-ng, listening on Channel 3 and filtering on the BSSID and saving the output to *wep1*.  Our goal is to capture the WPA 4-way handshake, which takes place when a wireless client connects and authenticates to the access point.

### Deauthentication Attack

We could passively capture the WPA handshake by allowing airodump-ng to run until a new wireless client connects and authenticates to our target network.  However, we could use a deauthentication attack on a connected client to speed up the process, which is what we will do here.

> root@attacker:~# **aireplay-ng -0 1 -a 34:08:04:09:3D:38 -c 00:18:4D:1D:A8:1F mon0**

After conducting the attack, you can look in the upper right hand corner of the airodump-ng output and should see the we hopefully captured the complete 4-way handshake.  In the event of not successfully capturing in, we can either re-run the deauthentication attack against the same client or we can run the attack against a different client.

### Preperation
#### Create Airolib Database (Optional)

Airolib-ng is designed to store and manage ESSID and password lists.  It computes their PMKs and use them to crack WPA and WPA2 passwords.  Since PMKs are reproducable due to the PMK always being the same for a given ESSID and password combination, we are able to pre-compute the PMKs for different combinations and possibly speed up the cracking of the handshake.

To get started, we need to create a file containing the ESSID of our target network.

> root@attacker:~# **echo hitme > essid.txt**

This enables us to import the new text file into the database

> root@attacker:~# **airolib-ng <dbName> --import essid essid.txt**

This will automatically create the database if it does not exist.

We can verify this by providing the `--stats` operation to airolib-ng

> root@attacker:~# **airolib-ng <dbName> --stats**

In the output, you should see the ESSID you imported in the ESSID column.  Now we need to import the password file.

> root@attacker:~# **airolib-ng <dbName> --import passwd <wordlist>**

You will see output indicating the file is being read, along with how many lines have been imported.

With all of the data imported, we now need to have airolib-ng all of the corresponding PMKs.

> root@attacker:~# **airolib-ng <dbName> --batch**

You will see output indicating how many PMKs were generated, the time taken and the generation rate.  This can also be validated with the `--stats` operation also.  You will see 100.0 in the `Done` column, indicating 100% completion.

#### Prepare John the Ripper

Using a wordlist with John the Ripper will not yield any results that aircrack-ng would render.  For this reason, we will configure JTR to use word mangling.

> nano /etc/john/john.conf

At the endo of the section `List.Rules.Wordlist`, add the following 2 lines

> $[a-zA-Z0-9]$[a-zA-Z0-9]
> $[0-9]$[0-9]$[0-9]

We have added 2 rules.  The first will add to characters on to each word in the wordlist, using only the defined charcter(upper and lowercase letters plus, zero to nine).  The second adds 3 characters all 0-9.

#### coWPAtty Rainbow Tables

This is the main purpose behind coWPAtty, to make use of pre-compiled hashes for cracking WPA passwords.  The pre-computed hashes are generated for each unique ESSID.

For this, we will use `genpmk`, a tool included with coWPAtty.

> root@attacker:~# **genpmk -f <wordlist> -d hitme-hashes -s hitme**

Similar to airolib-ng, genpmk will provide output showing how many passphareses were testing and the total time taken, along with through put.

### Crack the WPA Key

We have the 4-way handshake for the target network.  Let's look at how to crack this with aircrack-ng and airolib-ng.
#### Wordlist-based Crack

Very similar to how we executed a wordlist based crack for WEP, we shall also do for WPA/WPA2

> root@attacker:~# **aircrack-ng -w <worldlist> wpa-psk-01.cap

We can analyze the output for aircrack-ng to see whether we were able to crack the WPA PSK or not.

#### Airolib Database-based Crack

Aircrack-ng has airolib-ng support built in natively.  we just pass the `-r` parameter instead of the `-w`.

> root@attacker:~# **aircrack-ng -r <dbName> wpa-psk-01.cap**

In the output, you will notice a substantial increase in the number of keys tested per second.

#### Aircrack-ng with JTR

Now that John is configured to mangle words in the wordlist, we can increase our chances of finding the WPA key.

> root@attacker:~# **./john --wordlist=<wordlist> --rules --stdout | aircrack-ng -d hitme -w - wpa-psk-01.cap**

Despite using JTR, you will see the aircrack-ng output on your screen, not JTR's output.

#### coWPAtty Dictionary Mode

Dictionary mode is not the reason most people use coWPAtty, but it is still a good idea to know how to use it.

> root@attacker:~# **cowpatty -r wpa-psk-01.cap -f <wordlist> -2 -s hitme

The one thing to note about the command above, is the use of the `-2` parameter.  This tells coWPAtty to use non-strict mode since coWPAtty has an issue with Airdump-ng captures.

#### coWPAtty Rainbow Tables Mode

Now that we have our handshake and pre-computed hashes, we can now crack the WPA password

> root@attacker:~# **cowpatty -r wpa-psk-01.cap -d hitme-hashes -2 -s hitme**

coWPAtty's output will display the PSK if we were successful.
