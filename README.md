# README

Introducing DSC_LABS. This is a demo based run-through on deploying and managing Desired State Configuration (DSC).

## Features
* Deploy a jump server for use with dsc.
* Deploy dc01, dc02, certificate server, and dsc pull server (IIS web server).
* Then, deploy and manage nodes with dsc.
* Full demos on how to use dsc to manage Windows Server 2012 R2, Windows Server 2016, Windows Server 2019, and Ubuntu 20.04
* Learn to create self-signed certificates to manage freshly deployed guests from template 
* Learn to create CA-signed certificates in lab.local (the domain you create)
* Learn to use the pull server to securely configure and manage all nodes.

## Requirements
- Requires Microsoft ISE and/or VS Code
- Requires hardware to run one or more virtual machines

## Virtualization Type
- `kvm`    - For this fork we are using `kvm` which is available for free on `ubuntu`.
- `VMware` - For a fully automated deploy of dsc labs using VMware technologies, see the original repo at [https://github.com/vmkdaily/DSC_LABS/tree/master/vmw](https://github.com/vmkdaily/DSC_LABS/tree/master/vmw). 

## Credits
DSC_LABS uses some helper functions and techniques from https://github.com/Duffney/#
