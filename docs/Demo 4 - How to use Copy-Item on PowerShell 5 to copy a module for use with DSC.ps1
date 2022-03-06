## How to use Copy-Item on PowerShell 5 to copy a module for use with DSC

## Introduction
## This demo shows how to copy files to a remote node using PowerShell Copy-Item.

#clear errors
$error.clear();Clear-Host

## create a session
$ComputerName = 'dscpull01' #Name or IP Address of remote node.
$nodeCreds = Get-Credential ('{0}\Administrator' -f $ComputerName)
$session = New-PSSession -ComputerName $ComputerName -Credential $nodeCreds

#Note: If you get errors performing the above, then check your WinRM settings:
psedit "C:\DSC_LABS\docs\Demo 2 - How to handle WinRM trusted hosts.ps1"

##show session
$session

## Run command on remote nodes
Invoke-Command -Session $session -ScriptBlock {
    gci "C:\Program Files\WindowsPowerShell\Modules\xNetworking" -ea Ignore
}

################
## copying bits
################

## Option A - Copy One Module
$Params = @{
    Path         = 'C:\Program Files\WindowsPowerShell\Modules\ComputerManagementDsc'
    Destination  = 'C:\Program Files\WindowsPowerShell\Modules\'
    ToSession    = $session
    Recurse      = $true
    Verbose      = $true
}
Copy-Item @Params

# Option B - Copy multiple Modules
$list = Get-ChildItem 'C:\Program Files\WindowsPowerShell\Modules\' | Select-Object -ExpandProperty Name
foreach($mod in $list){
    $Params = @{
        Path         = ('C:\Program Files\WindowsPowerShell\Modules\{0}' -f $mod)
        Destination  = 'C:\Program Files\WindowsPowerShell\Modules\'
        ToSession    = $session
        Recurse      = $true
        Verbose      = $true
    }
    #do the copy action
    Copy-Item @Params
}


## Next, see how to execute commands on remote sessions with native PowerShell Remoting (WinRM):
psedit "C:\DSC_LABS\docs\Demo 5 - How to execute commands on remote sessions with native PowerShell Remoting (WinRM).ps1"
