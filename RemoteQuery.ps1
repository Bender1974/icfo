
<#
PowerShell
Version : 5.0

Program to retrieve:
        - all the users with admin rights in a remote computer in revers alphabetical order
        - or all the programs installed in a remote computer whose name starts with a vowel 

AUTHOR      :  Xavier Canas
LAST UPDATED:  22/04/2019
#>

Function RemoteQuery.ps1    #Set a name to the function
{

[Alias('RQ')]    #Set an alias for the function's name

    PARAM
        (
        [Parameter(Mandatory=$True)]
        $RemoteComputer
        #Specifies the target computer for data query in first parameter (-remotecomputer).
        #"Mandatory" means the parameter is always requiered#
        ,
        [Parameter(Mandatory=$true)]
        [ValidateSet("AdminUsers","InstalledSoftware")]
        $AskFor
        #Specifies the only two accepted values in the second parameter (-InstalledSoftware)
        #"ValidateSet" sends a message for invalid values
        )

    PROCESS
        {
        IF($AskFor -match 'AdminUsers')
        #Execute the next commands if the value of "Askfor" parameter matches with "AdminUsers"
        {
        $query="Associators of {Win32_Group.Domain='$RemoteComputer',Name='Administrators'} where Role=GroupComponent"  #from wbemtest
        get-wmiobject -query $query -ComputerName $RemoteComputer | Select Name | sort-object name -descending
        $group=get-wmiobject win32_group -filter "name='Administradores'"
        #Gather a list of users and groups from administrators local group in revers alphabetical order
        
        # It also works like this:
        # $group=get-wmiobject win32_group -filter "name='Administrators'" -ComputerName $RemoteComputer 
        # $group.GetRelated("win32_useraccount") | format-wide -column 1
        # $group.GetRelated("win32_systemaccount") | format-wide -column 1
        
        #or
        
        # Gwmi win32_groupuser -ComputerName $RemoteComputer  | where-object {$_.groupcomponent –like '*"Administrators"'} | format-wide -column 1  -Property partcomponent
        
        }
        Elseif ($AskFor -match 'InstalledSoftware')
        #Execute the next commands if the value of "Askfor" parameter matches with "InstalledSoftware"
        {
        Get-wmiobject Win32_Product -computername $RemoteComputer | where-object {($_.name -match "^a.*|^e.*|^i.*|^o.*|^u.*")} | Sort-object Name | format-wide -column 1
        #Gather a list of all programs installed whose name starts with one of these letters a,e,i,o,u
        Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-object DisplayName | where-object {($_.displayname -match "^a.*|^e.*|^i.*|^o.*|^u.*")} | Sort-object DisplayName 
        #Gather a similar list of installed programs according the registry values
        Write-output `n 
        #Adding a blank line to discriminate different sources 
        Get-ItemProperty HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-object DisplayName | where-object {($_.displayname -match "^a.*|^e.*|^i.*|^o.*|^u.*")} | Sort-object DisplayName
        #Gather another similar list from another folder of the registry
        }
        }
}

