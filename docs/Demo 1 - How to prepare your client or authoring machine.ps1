# How to prepare your client or authoring machine

## Intro
## We start by adding software to a "jump" box that we can use to build our environment.
## The assumption is that you are using Windows, so adjust as needed otherwise.
## Later, we review how to configure Linux nodes.

## About These Demos for "DSC_LABS"

  <#
    While it would be easier to read if we documented in markdown (i.e. *.md),
    most of the files are ".ps1" format so the desired lines can be run interactively.
    
    By using .ps1 files, we can highlight and run desired lines by pressing "F8".
    
    Note that we will never press "F5", which runs the entire script.
    
    These demos should work well with either:
    - Microsoft ISE
    - VS Code (with powershell extension installed)

  #>

## Install modules on your jump server or client

  Install-Module -Name xActiveDirectory
  Install-Module -Name xComputerManagement
  Install-Module -Name xDnsServer
  Install-Module -Name xNetworking
  Install-Module -Name xTimeZone
  Install-Module -Name xPSDesiredStateConfiguration
  Install-Module -Name xAdcsDeployment
  Install-Module -Name ComputerManagementDsc
  Install-Module -Name NetworkingDsc

## Optional - Install latest "PSDesiredStateConfiguration" side-by-side.
## For DSC_LABS, the default of version of "1.1" for "PSDesiredStateConfiguration" is fine.
## However, you can also install the latest side-by-side, by using the "-Force" parameter.

  Install-Module -Name PSDesiredStateConfiguration -Force

## Optional - Update PackageManagement

  Install-Module PackageManagement

## Optional - Install the PSPKI module (support for legacy guests). We do this in a later demo as well.

  Install-Module -Name PSPKI

## Next, we open Demo 2 to learn WinRM.
psedit "C:\DSC_LABS\docs\Demo 2 - How to handle WinRM trusted hosts.ps1"

