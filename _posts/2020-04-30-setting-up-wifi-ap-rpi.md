---
title: Setting up a Rasberry Pi as a Wireless AP
category: wifi security
layout: post
author: jesse
thumbnail: /assets/img/wifi.png
date: 2020-05-04T00:00:00:01.613Z
summary: Using a raspberry pi to create a wireless access point
keywords: access wifi ap wpa wpa2 psk rpi
permalink: /blog/setup-wifi-ap-rpi/
---

Whether you are looking to expand your wifi network or want a wifi pen testing lab, it is always good to know how to turn a Raspberry Pi into a wireless access point.

## Table of Contents
* [Overview](#overview)
* [Requirements](#requirements)
* [Instructions](#instructions)
  * [Update Raspbian](#update-raspbian)
  * [Install hostapd and dnsmasq](#install-hostapd-and-dnsmasq)
  * [Configure a static IP](#configure-a-static-ip)
  * [Configure the DHCP server(dnsmasq)](#configure-the-dhcp-serverdnsmasq)
  * [Configure the access point host software](#configure-the-access-point-host-software)
  * [Setting up traffic forwarding](#setting-up-traffic-forwarding)
  * [Add iptables rule](#add-iptables-rule)
* [hostapd sample configurations](#hostapd-sample-configurations)
  * [WEP Open Authentication](#wep-open-authentication)
  * [WEP Pre-Shared Key Authentication](#wep-pre-shared-key-authentication)
  * [WPA-PSK](#wpa-psk)
  * [WPA2-PSK](#wpa2-psk)
  * [WPA2 Enterprise](#wpa2-enterprise)
  
## Overview

The Raspberry Pi has many various uses.  One of those uses is a Raspberry Pi can be a wireless access point.  Why would someone use a Raspberry Pi as a wireless access point?  Two primary reasons come to mind. First, if you are interested in hacking/pen testing wifi networks, a Raspberry Pi is an efficient access point and makes changing the AP configuration quite efficient.  Second, with using 2 wifi adapters, you can turn it into a range extender for your home or business.

## Requirements

There are a few items you will need for doing this project:
* Rasberry Pi 3/4
* 2 usb wireless adapters(Pi3), or 1 usb wireless adapter(Pi4)
  * If you plan to plug you Pi into ethernet, you can reduce the usb adapter requirement by 1
* MicroSD card 16GB+ with Raspbian installed

## Instructions

### Update Raspbian

    sudo apt-get update
    sudo apt-get install
    
If any of the packages were updated, we recommend you reboot before proceeding.

### Install hostapd and dnsmasq

**hostapd** is a user space daemon for access point and authentication servers.

    sudo apt-get install hostapd
    
**dnsmasq** is a lightweight DNS forwarder and DHCP server.

    sudo apt-get install dnsmasq
    
You will likely be prompted to confirm the install, press `y` to continue.

Once both are installed, we need to stop their services from running so that we can edit their configuration.

    sudo systemctl stop hostapd
    sudo systemctl stop dnsmasq
    
### Configure a static IP

For simplicity, I am going to assume this is being used on a home network and we are using the standard home IP addresses, like 10.0.X.X.  Given that assumption, let's provide the IP address of 10.0.0.10 to either wlan0 or eth0, depending on whether you plan to use wifi or ether for the network connection.

_NOTE: If yoy are planning to use this for wifi hacking, we suggest keeping it off your home network since the configuration will inherently be insecure._

    sudo nano /etc/dhcpcd.conf
    
Once in the file, add the following to the bottom of the file

    interface wlan0 (or eth0)
    static ip_address=10.0.0.10/24
    denyinterfaces eth0
    denyinterfaces wlan0
    
Those `denyinterfaces` lines at the end are needed to make our bridge work.  Now, save the file and exit.

### Configure the DHCP server(dnsmasq)

 We need a DHCP server so that we can dynamically distribute network configuration parameters, like IP address, for interfaces and services.
 
 The default configuration is a bit bloated, so let's rename the file to something else and create a fresh version
 
    sudo mv /etc/dnsmasq.conf /etc/dnsmasq.conf.old
    sudo nano /etc/dnsmasq.conf
    
Now let's edit the file to configure our interface and DHCP IP range:

    interface=wlan0
      dhcp-range=10.0.0.11, 10.0.0.30,255.255.255.0,24h
      
### Configure the access point host software

Let's open the hostapd config file

    sudo nano /etc/hostapd/hostapd.conf
    
This should create a new file, however, if it opens an existing version of the config file, delete the contents before proceeding.

Let's add the following into the file:

    interface=wlan0
    bridge=br0
    hw_mode=g
    channel=<channel>
    wmm_enabled=0
    macaddr_acl=0
    auth_algs=1
    ignore_broadcast_ssid=0
    wpa=2
    wpa_key_mgmt=WPA-PSK
    wpa_pairwise=CCMP
    ssid=<network>
    wpa_passphrase=<password>
    
Make sure to set the `channel`, `ssid` and `wpa_passphrase` to your desired configuration.  This configuration as you can probably tell is for creating a WPA2 access point.

Now we need to hell the system the location of the config file.  For that we will do the following:

    sudo nano /etc/default/hostapd
    
Find the line that starts with `#DAEMON_CONF=""` -- delete the `#` and put the path to the config file we just created/edited:

    DAEMON_CONF="/etc/hostapd/hostapd.conf"
    
### Setting up traffic forwarding

If you were to connect to the access point now, you would notice that after connecting it would tell you that there is not internet access.  This is because your Pi is not currently configured to forward the traffic it receives via wlan0 over you ethernet connection to your modem/gateway.

To adjust this, let edit the following file

    sudo nano /etc/sysctl.conf
    
Find the line that begins with `#net.ipv4.ip_forward=1`, and delete the `#`, leaving the rest of the line intact.

### Add iptables rule

Now we will setup IP masquerading for outbound traffic on eth0

    sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
    
Not, let's save the new rule:
    
    sudo sh -c "iptables-save > /etc/iptables.ipv4.nat"
    
Next, we set the rule to load on boot, by adding the following line to the `/etc/rc.local` file just above the line: `exit 0`:

    iptables-restore < /etc/iptables.ipv4.nat
    
We are almost finished configuring the Pi as a fully functional access point.  The last task is adding a bridge to pass all the traffic between the wlan0 and eth0 interfaces.

We will need to install another packet to achieve this:

    sudo apt-get install bridge-utils
    
Add the new bridge
   
    sudo brctl addbr br0

Let's add our eth0 interface to the bridge

    sudo brctl addif br0 eth0
    
And now we just need to edit the interfaces file to add the bridge

    sudo nano /etc/network/interfaces
    
Now, add the following lines to the bottom of the file:

    auto br0
    iface br0 inet manual
    bridge_ports eth0 wlan0
    
Phew, we are done, now we need to reboot and when the Pi comes back up, it should be a working access point.

    sudo reboot
    
## hostapd sample configurations

The following examples are overly simplistic and the minimal needed for running hostapd.  There are quite a few possibly settings the can be added and should be added to the configuration if you are doing anything more than setting up a Wifi pen testing lab.

### WEP Open Authentication

    interface=wlan0
    driver=nl80211
    bridge=br0
    hw_mode=g
    channel=<channel>
    wmm_enabled=0
    macaddr_acl=0
    ignore_broadcast_ssid=0
    auth_algs=2
    ssid=<network>
    
### WEP Pre-Shared Key Authentication

The key length should be 5, 13, or 16 characters, or 10, 26, or 32 digits, depending on whether 40-bit (64-bit), 104-bit (128-bit), or 128-bit (152-bit) WEP is used

    interface=wlan0
    driver=nl80211
    bridge=br0
    hw_mode=g
    channel=<channel>
    wmm_enabled=0
    macaddr_acl=0
    ignore_broadcast_ssid=0
    auth_algs=2
    wep_default_key=0
    wep_key0=<key>
    ssid=<network>
    
### WPA-PSK

    interface=wlan0
    driver=nl80211
    bridge=br0
    hw_mode=g
    channel=<channel>
    wmm_enabled=0
    macaddr_acl=0
    ignore_broadcast_ssid=0
    auth_algs=1
    ssid=<network>
    wpa=1
    wpa_key_mgmt=WPA-PSK
    wpa_passphrase=<password>

### WPA2-PSK

    interface=wlan0
    driver=nl80211
    bridge=br0
    hw_mode=g
    channel=<channel>
    wmm_enabled=0
    macaddr_acl=0
    ignore_broadcast_ssid=0
    auth_algs=1
    ssid=<network>
    wpa=2
    wpa_key_mgmt=WPA-PSK
    rsn_pairwise=CCMP
    wpa_passphrase=<password>
    
### WPA2 Enterprise

Here is a configuration that uses hostapd's internal RADIUS server, though it is possible to use FreeRADIUS as well.

/etc/hostapd.conf

    interface=wlan0
    ctrl_interface=/var/run/hostapd
    ctrl_interface_group=wheel
    ssid=<network>
    wpa=2
    wpa_key_mgmt=WPA-EAP
    wpa_pairwise=TKIP CCMP
    macaddr_acl=0
    auth_algs=1
    own_ip_addr=127.0.0.1
    ieee8021x=1
    eap_server=1
    eapol_version=1
    
Add the path for the EAP server user database to the end of the file

    eap_user_file=/etc/hostapd_eap_user
    ca_cert=/etc/ssl/<ca cert>
    server_cert=/etc/ssl/<ssl cert>
    private_key=/etc/ssl/<private key>
    
/etc/hostapd_eap_user

    "jesse@domain.tld" PEAP [ver=0]
    "jesse@domain.tld" MSCHAPV2 "<passphrase>" [2]
    
To make things more secure, you could just use this one line to require a client certificate

    "jesse@domain.tld" TLS
    
