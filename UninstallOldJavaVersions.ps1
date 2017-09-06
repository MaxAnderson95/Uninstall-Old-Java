<#

.SYNOPSIS
This PowerShell script removes old versions of Java based on the inputted "current" version

.DESCRIPTION
This PowerShell script recieves an inputted "Current Java Version GUID" and uses MSIEXEC to remove all other versions of Java except for this version

.EXAMPLE
.\UninstallOldJavaCersions.ps1 -CurrentVersionGUID 26A24AE4-039D-4CA4-87B4-2F32180144F0

.EXAMPLE
.\UninstallOldJavaCersions.ps1 -CurrentVersionGUID {26A24AE4-039D-4CA4-87B4-2F32180144F0}

.PARAMETER CurrentVersionGUID
This parameter accepts GUIDs with and without being wrapped in braces if the parameter is specified durring inital run. This is due to how PowerShell parces parameter input and automatically removes braces. 
If the parameter is not specified when the command is run, the parameter (being mandatory) will ask the user to input it and will not accept the input wrapped in braces.

#>

#Specifies a mandatory parameter named "CurrentVersionGUID" that validates the input based on a regular expression
Param (
    [Parameter(Mandatory=$true)]
    [ValidatePattern("^[A-Z0-9]{8}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{12}$")]
    [String]$CurrentVersionGUID
)

$error.clear()

#Gets a list of apps from WMI that have: "Java" in the name, that do not have the current version GUID, and no do not also have "audo updater" in the name
$Apps = Get-WmiObject -Class "Win32_Product" | Where-Object { $_.Name -like "*Java*" -and $_.IdentifyingNumber -ne "{$CurrentVersionGUID}" -and $_.name -notlike "*auto updater*" }

#Loops through each app found, and runs msiexec /X /qn with the GUID of the undesired version of Java. 
ForEach ($App in $Apps) {
    Start-Process "msiexec.exe" -ArgumentList "/X $($App.IdentifyingNumber) /qn" -wait
}
