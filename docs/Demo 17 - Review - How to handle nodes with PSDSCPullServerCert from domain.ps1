# Review - How to handle nodes with PSDSCPullServerCert

## Introduction
<#
    For the test node, we assume it is a domain member,
    and thus has a CA-signed certificate from lab.local.

    Here we gather information we can use when
    creating the lcm for this node.
#>

$ComputerName = 's2.lab.local'
$creds = Get-Credential LAB\Administrator
$session = New-PSSession -ComputerName $ComputerName -Credential $creds

## Show all certs
Invoke-Command -Session $session -ScriptBlock { Get-ChildItem Cert:\LocalMachine\my }

## Get lab.local cert from node
$cert = Invoke-Command -Session $session -ScriptBlock {
    Get-ChildItem Cert:\LocalMachine\my | 
    Where-Object {$_.Issuer -eq 'CN=lab-CERT01-CA, DC=LAB, DC=LOCAL' `
    -and $_.PrivateKey.KeyExchangeAlgorithm `
    }
}

## show cert
$cert

## Extract thumbprint
$thumbprint = $cert.thumbprint

## Show details
Write-Host '//Node Summary' -ForegroundColor Magenta
Write-Host ''
Write-Host $ComputerName -ForegroundColor Green -BackgroundColor DarkGreen
Write-Host ('{0}' -f ($cert | Select-Object -ExpandProperty Subject)) -ForegroundColor Green
Write-Host $thumbprint -ForegroundColor Green

## Summary
<#

    This demo showed how to get the required information
    from a remote node that has the lab.local cert (obtained via GPO).

    If you got this far, you have full control over Windows.
    Next, we move on to Linux with dsc.

    Note: You will need vs code to read the markdown (.md) files of the final two demos.

#>

## Next, we learn to prepare Ubuntu 20.04 for dsc
## For this, we launch VS Code since the file is written in markdown.
code "C:\DSC_LABS\docs\Demo 18 - How to prepare Ubuntu 20.04 LTS Linux for DSC.md"