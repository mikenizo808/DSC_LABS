## The DSC Lab
Welcome to `DSC_LABS`. This document describes the overview of required components.
You can adjust your network and names as needed.

This document is written in markdown (`.md`) but note that most of the docs are `.ps1` files.


> Note: All examples use the Microsoft ISE or VS Code for editing and running demo scripts

## Domain name
The domain we create is `lab.local`

    lab.local

## Required virtual machines (dsc infrastructure)
These are example virtual machines; adjust names and IPs as desired.

    dscjump01       10.205.1.150
    dc01            10.205.1.151
    dc02            10.205.1.152
    cert01          10.205.1.153
    dscpull01       10.205.1.154

## Test machines we deploy
Once we have dsc up and running, we can deploy and re-deploy these nodes for testing.

    s1              10.205.1.155 (i.e. Windows Server 2019)
    s2              10.205.1.156 (i.e. Windows Server 2016)
    Linux01         10.205.1.157 (i.e. Ubuntu 20.04)



