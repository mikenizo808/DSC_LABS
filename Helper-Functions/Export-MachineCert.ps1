#Requires -Version 4
Function Export-MachineCert {
    <#
    .SYNOPSIS
        Harvests a certificate from a remote system.

    .DESCRIPTION
        Invokes a command on a remote system to copy the certificate to the machine running the command.

    .PARAMETER Computername
        Specifies the name of the remote system from which to harvest the certificate.

    .PARAMETER Path
        Provides the path where the certificate is copied to on the host system.

    .PARAMETER Template
        Specifies the template used when generating the certificate on the remote system.
    
    .NOTES
        Script: Export-MachineCert.ps1
        From:   Pluralsight Advanced DSC course, helper examples. Available on github.

    #>

    [cmdletbinding()]
    Param(
        [ValidateNotNullorEmpty()]
        [string]$computername = $env:COMPUTERNAME,
        [ValidateScript({Test-Path $_})]
        [string]$Path="$env:SystemDrive\Certs"
    )

    Try {
        #assumes a single certificate so sort on NotAfter
        Write-Verbose "Querying $computername for Machine certificates"
        $cert = Invoke-Command -ScriptBlock { 
            Get-ChildItem Cert:\LocalMachine\my | 
            Where-Object {$_.EnhancedKeyUsageList.FriendlyName -eq 'Document Encryption'}
        } -ComputerName $computername -ErrorAction Stop
        write-verbose ($cert | out-string)

        if($null -ne $cert -and (($cert.count) -gt '1')){$cert = $cert[0]}
    }
    Catch {
        Throw $_
    }

    if($null -ne $cert) {
        #verify and export
        if (Test-Certificate $cert) {
            $exportPath  = Join-path -Path $Path -ChildPath "$computername.cer"
            Write-Verbose "Exporting certificate for $($cert.subject.trim()) to $exportpath"
            [pscustomobject]@{
                Computername = $cert.Subject.Substring(3)
                Thumbprint = $cert.Thumbprint
                Path = Export-Certificate -Cert $cert -FilePath $exportPath
            } 
        } #if Test OK $cert
        else {
            Write-Warning "Failed to verify or find a certificate"
        }
    } #if $cert
} #Export-MachineCert