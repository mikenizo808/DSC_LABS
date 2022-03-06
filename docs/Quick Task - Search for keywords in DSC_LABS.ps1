## How to search for keywords in DSC_LABS

    # what to search for
    $keyword =  'WinRM'
    
    # search .ps1 files
    Get-ChildItem -Path "c:\dsc_labs\" -Recurse -Include *.ps1 | Select-String $keyword
