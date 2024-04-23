#Created by DroidKid
#Updated on: May 2022
#Version: 1.0
#This script will install the new Quick assist and remove the old version
#Switches used are "-install" and "-uninstall"

#sets switches
param
(
    [Parameter(Mandatory=$false)][Switch]$Install,
    [Parameter(Mandatory=$false)][Switch]$Uninstall,
    [Parameter(ValueFromRemainingArguments=$true)] $args
)

#Log output results
function LogOutput($Message) {
    $LogFile = "C:\Quick-Assist.log"
    "$(get-date -Format 'MM/dd/yyyy HH:mm') $($Message)" | Out-file -FilePath $LogFile -Append -Force
}

#Start of Script
If ($Install){
	Try {
		LogOutput "***This script is used to install the new Quick Assist app that is from the Microsoft Store. It will also remove the old version***"
		$InstallAppX = Get-AppxPackage -allusers MicrosoftCorporationII.QuickAssist
		If ($InstallAppX.status -eq 'OK'){
			LogOutput "[Info] Windows Store version of Quick Assist is already installed" 
			#lets uninstall the old version.
			LogOutput "[Info] lets uninstall the old version" 
			Remove-WindowsCapability -Online -Name 'App.Support.QuickAssist~~~~0.0.1.0' -ErrorAction 'SilentlyContinue'
			LogOutput "[Info] Old version of Quick Assist has been uninstalled" 
		}
		If ($InstallAppX.status -ne 'OK'){
			LogOutput "[Info] Installing the Windows Store version of Quick Assist..."
			Add-AppxProvisionedPackage -online -SkipLicense -PackagePath '.\MicrosoftCorporationII.QuickAssist.AppxBundle'
			LogOutput "[Info] Attempting to remove the old version of Quick Assist..."
			Remove-WindowsCapability -Online -Name 'App.Support.QuickAssist~~~~0.0.1.0' -ErrorAction 'SilentlyContinue'
		}
		LogOutput "[Success] The Windows store version of Quick assist has successfully installed and the old version has been removed." 
	} catch [exception] {
		LogOutput "[Error] An error occurred installing Quick Assist: $($_.Exception.Message)" 
	}
}

If ($Uninstall){
	Try {
		LogOutput "***This script is used to uninstall all versions of Microsoft Quick Assist***"
		$AppXStatus = Get-AppxPackage -allusers MicrosoftCorporationII.QuickAssist
		#Check to see if the Windows Store version of Quick Assist is installed. Also, lets force an uninstall of the old version just in case 
		If ($AppXStatus.status -ne 'OK'){
			Remove-WindowsCapability -Online -Name 'App.Support.QuickAssist~~~~0.0.1.0' -ErrorAction 'SilentlyContinue'
			LogOutput "[Info] Windows Store version of Quick Assist was not found." 
		}
		#Lets uninstall the Windows Store version of Quick Assist and the old version just in case.
		If ($AppXStatus.status -eq 'OK'){
			Get-AppxPackage -allusers MicrosoftCorporationII.QuickAssist | Remove-AppxPackage -allusers
			Remove-WindowsCapability -Online -Name 'App.Support.QuickAssist~~~~0.0.1.0' -ErrorAction 'SilentlyContinue'
		}
		LogOutput "[Info] The Windows store version of Quick Assist has successfully been uninstalled." 
	} catch [exception] {
		LogOutput "[Error] An error occurred uninstalling The Windows store version of Quick Assist: $($_.Exception.Message)" 
	}
}