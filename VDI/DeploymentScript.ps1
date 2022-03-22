######BEGIN SCRIPT######

#NOTE: This script was written in VSCode and is best viewed using VSCode.

<#
---------------------------------Author--------------------------------------
                                
                               Alec McClure

-------------------------------------------------------------------------------#>
<#
.SYNOPSIS
 This script is designed to Set the static IP Address, Join a domain, and Install 
 various applications after the intial login of Windows.

.DESCRIPTION
-------------------------------Description---------------------------------------
This script will ask for a Computer Name and IP Address. Using this information 
it will set a Static IP Address, Join the computer to the ilcp.circ7.dcn domain,
And download the Installers for the next step.
-------------------------------------------------------------------------------#>

######Declare Variables######

#Set Progress Bars to Silent [REQUIRED]
$Global:ProgressPreference = 'SilentlyContinue'
Clear-Host

#Script Variables for different checks
$script:MenuExit = 0

#Local Installer Path 
$windeployapps = "C:\Users\Administrator\Documents\Deployment\ApplicationInstallers"

######Main Functions######

#Main Menu Look
function MainMenu {
    param (
        [string]$Title = 'Main Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "`nIf performing this on a new computer Enter 'A' to perform the recommended actions.`n"
    Write-Host "`n================ $Title ================`n"
    Write-Host "1: Press '1' Install An Application"
    Write-Host "Q: Press 'Q' to quit."
}

#Display the Main Menu
function show-MainMenu {
    do {
        MainMenu
        $selection = Read-Host "`nPlease make a selection"
        switch ($selection) {
            '1' {
                show-applicationmenu
            }
        }
    }
    until ($selection -eq 'q' -or $script:MenuExit -eq 1)   
} 

#Application Installer Menu
function ApplicationMenu {
    param (
        [string]$Title = 'Application Installer Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "A: Press 'A' to install All Listed Applications"
    Write-Host "1: Press '1' to install Adobe"
    Write-Host "3: Press '2' to install Firefox"
    Write-Host "5: Press '3' to install Office 365"
    Write-Host "Q: Press 'Q' to quit."
}

#Installer Functions
#NOTE: Edit these functions or use as a template for applications you wish to install
function AdobeInstall {
    Write-Host "`nInstalling Adobe "
    Start-Process "$windeployapps\AdobeAcrobat\setup.exe" -Wait
}

function Office365Install {
    Write-Host "`nInstalling Office365"
    Start-Process "$windeployapps\Office365\setup.exe" -ArgumentList "/configure C:\windeployapps\Office365\ILCP-VDI-Office365_x64-config.xml" -Wait
}

function FirefoxInstall {
    #NOTE: This application requires a policies.json file to import the system certificates for Corporate use.
    Write-Host "`nInstalling Firefox"
    Start-Process msiexec.exe -ArgumentList "/I $windeployapps\Firefox\firefox.msi /passive" -Wait
    
    Start-Sleep -Seconds 2
    
    Start-Process firefox.exe
    
    Start-Sleep -Seconds 1
    
    Stop-Process -Name firefox

    #Runs the following command:
    #New-Item -Path "C:\Program Files\Mozilla Firefox" -ItemType Directory -Name "distribution"
    powershell.exe "$windeployapps\Firefox\firefox_config.ps1"

    Start-Sleep -Seconds 1

    #Copies the policies.json file to the newly created distribution folder
    Copy-Item -Path "$windeployapps\Firefox\policies.json" -Destination "C:\Program Files\Mozilla Firefox\distribution"
    
    #NOTE: the policies.json file contains the following code:
    #{
    #"policies": {
    #    "Certificates": {
    #      "ImportEnterpriseRoots": true
    #    }
    #  }
    #}
    
    #NOTE 2: This is required for Firefox to use Enterprise Certificates for any user that logs onto the computer.
}

#Install All Applications
#NOTE: Be sure to edit this function to reflect the Applications you want to install
function Install-ALL {
    Clear-Host

    AdobeInstall
    
    Start-Sleep -Seconds 5
    
    FirefoxInstall
    
    Start-Sleep -Seconds 5
    
    Office365Install
}

#Display the Application Installer Menu
function show-applicationmenu {
    
    get-installers #Mounts Application Installers Drive and Copies the installers to local folder
    
    do {
        ApplicationMenu
        $selection = Read-Host "`nPlease make a selection"
        switch ($selection) {
            '1' {
                AdobeInstall
            } 
            '2' {
                FirefoxInstall
            }
            '3' {
                Office365Install
            }
            'A' {
                Install-ALL
            }
        }
    }
    until ($selection -eq 'q')
}

######Running The Script######

show-MainMenu

Clear-Host

######END OF SCRIPT######