
<#
PowerShell
Version : 5.0

Program to retrieve:
        - all the users with admin rigths in a remote computer in revers alphabetical order
        - or all the programs installed in a remote computer whose name starts with a vowel 

AUTHOR      :  Xavier Cañas
LAST UPDATED:  22/04/2019
#>

Function RemoteQuery.ps1
{

[Alias('RQ')]

    PARAM
        (
[Parameter(Mandatory=$True)]
$RemoteComputer    #Specifies the target computer for data query in first parameter (-remotecomputer)
 ,
[Parameter(Mandatory=$true)]
[ValidateSet("AdminUsers","InstalledSoftware")]    #Specifies the only two accepted values in the second parameter (-InstalledSoftware)
$AskFor
        )
                
    PROCESS
        {
IF($AskFor -match 'AdminUsers')
{
$query="Associators of {Win32_Group.Domain='$RemoteComputer',Name='Administradores'} where Role=GroupComponent"
get-wmiobject -query $query -ComputerName $RemoteComputer | Select Name | sort-object name -descending
#Gather a list of users and groups from administrators local group in revers alphabetical order
}
Elseif ($AskFor -match 'InstalledSoftware')
{
Get-wmiobject Win32_Product -computername $RemoteComputer | where-object {($_.name -match "^a.*") -or ($_.name -match "^e.*") -or ($_.name -match "^i.*") -or ($_.name -match "^o.*") -or ($_.name -match "^u.*")} | Sort-object Name | format-wide -column 1
Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-object DisplayName | where-object {($_.displayname -match "^a.*") -or ($_.displayname -match "^e.*") -or ($_.displayname -match "^i.*") -or ($_.displayname -match "^o.*") -or ($_.displayname -match "^u.*")} | Sort DisplayName 
Write-output `n 
Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-object DisplayName | where-object {($_.displayname -match "^a.*") -or ($_.displayname -match "^e.*") -or ($_.displayname -match "^i.*") -or ($_.displayname -match "^o.*") -or ($_.displayname -match "^u.*")} | Sort DisplayName
#Gather a list of all programs installed whose name starts with one of these letters a,e,i,o,u
}
        }
}

