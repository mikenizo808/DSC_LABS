## How to edit hosts file from ISE

## Introduction
<#
    Here we can optionally configure our Windows "hosts" file.
    This helps with name resolution while building out lab.local.

    The Windows "hosts" file syntax is quite forgiving, and you can tab between entries.
    
    We will populate using:

        ip      hostname        fqdn

#>

## Option 1 - Edit manually, then save.
psedit C:\windows\system32\drivers\etc\hosts

## Option 2 - Or, use PowerShell.
## You can only do this once, then you need to edit instead using above technique.
##
## create a variable to hold desired settings.
## set your IP Addresses and names as desired.
$hostsContent = @"
10.205.1.151    dc01        dc01.lab.local
10.205.1.152    dc02        dc02.lab.local
10.205.1.153    cert01      cert01.lab.local
10.205.1.154    dscpull01   dscpull01.lab.local
10.205.1.155    s1          s1.lab.local
10.205.1.156    s2          s2.lab.local
"@

## make the change
Add-Content C:\windows\system32\drivers\etc\hosts $hostsContent

## Show details
Get-Content C:\windows\system32\drivers\etc\hosts

## ping / test connection
Test-Connection dc01

## Summary
<#
    This demo configured our local hosts file, which is optional.
    Use this technique if you want to sue shortnames instead of
    IP Address, even before joining nodes to the lab.local domain.
#>

## Next, learn how to use the Copy-Item powershell cmdlet.
psedit "C:\DSC_LABS\docs\Demo 4 - How to use Copy-Item on PowerShell 5 to copy a module for use with DSC.ps1"
