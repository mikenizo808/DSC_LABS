#### Testing the Pull Server

The real test is opening a web page to that xml we did earlier, or really just using dsc.
However, here we look at using `pester` to test your `dsc` setup.

## Connect to pull server

    Enter-PSSession dscpull01

## Install Pester
You will already have `pester`, but nonetheless.

    Install-Module Pester

## Change Directory
We expect that the `xPSDesiredStateConfiguration` module is already installed on the pull server since this is how we built it presumably.

    cd C:\Program Files\WindowsPowerShell\Modules\xPSDesiredStateConfiguration\9.1.0\Modules\DscPullServerSetup\DscPullServerSetupTest

## Run the test

    Invoke-Pester ./DscPullServerSetupTest.ps1

## Results
Does your test pass?  Mine fails, but my `dsc` is working perfectly so who knows.  Open an issue here (or somewhere) if you have anything interesting.