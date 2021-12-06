######BEGIN SCRIPT######

####PLEASE READ THE READ ME DOC BEFORE RUNNING####

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

#Get Domain Admin Credentials[REQUIRED]
# Change DOMAIN\ADMIN ACCOUNT to your Domain and Domain Administrator Username
# For example: CONTOSO\Administrator
$Credential = Get-Credential "DOMAIN\ADMIN ACCOUNT"

#Set Progress Bars to Silent [REQUIRED]
$Global:ProgressPreference = 'SilentlyContinue'
Clear-Host

#Get Computer Name[REQUIRED]

<#
    If you use a naming scheme for your computers for different office locations
    then this is a critical step, as most automated tasks in this script
    use the computer name to determine what to do.
    i.e. Join a domain, search for an available ip address on the network.
#>

$script:name = Read-Host -prompt "`nEnter New Computer Name "

#Script Variables for different checks
$Script:IPCheckBool = $false
$script:MenuExit = 0

#Local Installer Path 
$windeployapps = "C:\WinDeployApps"

######Main Functions######

#Main Menu Look
function MainMenu {
    param (
        [string]$Title = 'Main Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "`nIf performing this on a new computer Enter 'A' to perform the recommended actions.`n"
    Write-Host "Description: `nThis script will ask for a Computer Name and IP Address.`nUsing this information it will set a Static IP Address, `nJoin the computer to the domain,`nAnd download the Installers for the next step."
    Write-Host "`n================ $Title ================`n"
    Write-Host "A: Press 'A' to Perform All Actions"
    Write-Host "1: Press '1' to Set An IP Address"
    Write-Host "2: Press '2' Join the Domain"
    Write-Host "3: Press '3' Install An Application"
    Write-Host "Q: Press 'Q' to quit."
}

#Display the Main Menu
function show-MainMenu {
    do {
        MainMenu
        $selection = Read-Host "`nPlease make a selection"
        switch ($selection) {
            '1' {
                show-IPmenu
            } 
            '2' {
                join-domain
            } 
            '3' {
                show-applicationmenu
            }
            'A' {
                Show-PerformMenu
            }
        }
    }
    until ($selection -eq 'q' -or $script:MenuExit -eq 1)   
} 

#Main Menu Option 1 Menu
function PerformAllMenu {
    param (
        [string]$Title = 'Perform All Menu'
    )
    Clear-Host
    Write-Host "`n================ $Title ================`n"
    Write-Host "1: Press '1' to Perform All Tasks With Auto Find IP"
    Write-Host "2: Press '2' to Perform All Tasks With Manual IP Entry"
    Write-Host "3: Press '3' to Perform All Tasks With Manual IP Settings"
    Write-Host "Q: Press 'Q' to Quit."
}

#Show the menu for Performing all Tasks and Perform All Tasks based on User Choice of IP Address Setting
function Show-PerformMenu {
    do {
        PerformAllMenu
        $choose = Read-Host -Prompt "Please Make A Selection"
        switch ($choose) {
            '1' {     
                show-IPmenu('1') #Set the Static IP Address

                Start-Sleep -Seconds 3
                
                join-domain #Join computer to the domain
                
                Start-Sleep -Seconds 3
                
                get-installers #Copy the installers to local folder
                
                Start-Sleep -Seconds 3
                
                Install-All 

                $script:MenuExit -eq 1
            }
            '2' { 
                show-IPmenu('2') #Set the Static IP Address

                Start-Sleep -Seconds 3
            
                join-domain #Join computer to the domain
            
                Start-Sleep -Seconds 3
            
                get-installers #Copy the installers to local folder
            
                Start-Sleep -Seconds 3
            
                Install-All

                $script:MenuExit -eq 1
            }
            '3' {
                show-IPmenu('3') #Set the Static IP Address

                Start-Sleep -Seconds 3
            
                join-domain #Join computer to the domain
            
                Start-Sleep -Seconds 3
            
                get-installers #Copy the installers to local folder
            
                Start-Sleep -Seconds 3
            
                Install-All

                $script:MenuExit -eq 1
            }
        }
    } until ($choose -eq 'q' -or $script:MenuExit -eq 1)
}

#Test if Domain Controller is responding
function test-alive($Servername) {
    if (Resolve-DnsName -Name $Servername -ErrorAction SilentlyContinue) {
        return $true
    }

    else {
        return $false
    }
}

#Join the Computer to the Domain 
#NOTE: Change $Domain content to your Domain and $Server to your Domain Controllers
function join-domain {
    #Change YOUR DOMAIN to your Fully Qualified Domain Name
    #For Example: example.contoso.com
    $Domain = "YOUR DOMAIN"

    <#
    Change NAMING SCHEME to your Computer Naming Scheme for example:
    A computer with the name CHWD10-TESTLT for a Chicago Laptop running Windows 10
    Would look like this: "CHWD*"

    If you have multiple locations use the commented out elseif statements to specify your
    other names for example:
    A computer in Peoria with the name PEWD10-TESTLT
    Would look like this: "PEWD*"
    #>

    if ($script:name -like "NAMING SCHEME") {
        #Replace DOMAIN CONTROLLER with the Server name of your Domain Controller
        #for example: MYDC01 
        $Server = "DOMAIN CONTROLLER"
        
        do {
            Write-Host "Waiting for $Server to Connect"
        }until (test-alive($Server))
        
        <#
            This is the command that adds the computer to the domain
            Replace OU COMPUTER PATH with the OU Path for your computer accounts
            in Active Directory.

            For Example if your domain is 'example.contoso.com' and your computer OU is under another OU called Seattle 
            OU COMPUTER PATH would look like this:
            OU=Seattle_Workstation,OU=Seattle,DC=example,DC=contoso,DC=com'
        #>
        Add-Computer -DomainName $Domain -DomainCredential $Credential -Server $Server -OUPath 'OU COMPUTER PATH' -NewName $script:name -Verbose
    }
    <#
    elseif ($script:name -like "NAMING SCHEME") {
        
        $Server = "OTHERDC"

        do {
            Write-Host "Waiting for $Server to Connect"
        } until (test-alive($Server))
        
        Add-Computer -DomainName $Domain -DomainCredential $Credential -Server $Server -OUPath 'OU COMPUTER PATH' -NewName $script:name -Verbose
    }

    elseif ($script:name -like "NAMING SCHEME") {
        
        $Server = "OTHERDC"
        
        do {
            Write-Host "Waiting for $Server to Connect"
        } until (test-alive($Server))

        Add-Computer -DomainName $Domain -DomainCredential $Credential -Server $Server -OUPath 'OU COMPUTER PATH' -NewName $script:name -Verbose
    }

    elseif ($script:name -like "NAMING SCHEME") {
        
        $Server = "OTHERDC"
        
        do {
            Write-Host "Waiting for $Server to Connect"
        } until (test-alive($Server))

        Add-Computer -DomainName $Domain -DomainCredential $Credential -Server $Server -OUPath 'OU COMPUTER PATH' -NewName $script:name -Verbose
    }
    #>
    else {
        Write-Host "Your Computer Name Did Not Match our Naming Scheme.`n`nPlease try again!" -ForegroundColor Red
        Exit
    }
    
    Start-Sleep -Seconds 3
}

#Set IP Address Menu
function IPmenu {
    param (
        [string]$Title = 'Set IP Address'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host "Description:`n`nSelecting Option '1' will search an IP range and Auto-Set"
    Write-Host "the DNS Servers and Gateway based on the Computer Name."
    Write-Host "`nSelecting Option '2' will allow you to set the IP address"
    Write-Host "yourself but Auto-Set the DNS Servers and Gateway based on the computer name"
    Write-Host "`nSelecting Option '3' will allow you to set the IP Address, DNS Servers, and Gateway yourself."
    Write-Host "`n================ $Title ================`n"
    Write-Host "1: Press '1' to Auto Search for a Free IP Address"
    Write-Host "2: Press '2' to Enter the IP Address"
    Write-Host "3: Press '3' to Enter IP, DNS, and Gateway Manually"
    Write-Host "Q: Press 'Q' to Quit."
}

#Test if the IP Address either auto generated or manually entered is available
function test-IPaddress ($testIP) {
    Write-Host "`nTesting $testIP`n" -ForegroundColor Blue
    $netconnectResult = Test-NetConnection $testIP -WarningAction SilentlyContinue

    try {
        if (Resolve-DnsName $testIP -ErrorAction Stop) {
            $DNSLookupResult = $true
        }
    }
    catch {
        $DNSLookupResult = $false
    } 

    $PingSucceeded = $netconnectResult.PingSucceeded

    if ($PingSucceeded -eq $false -and $DNSLookupResult -eq $false) {
        $Script:IPCheckBool = $true
        Write-Host "`nIP Address Available! : $testIP`n" -ForegroundColor Green
        Start-Sleep -Seconds 5
    }
    elseif ($PingSucceeded -eq "Success" -or $DNSLookupResult -eq $true) {
        $Script:IPCheckBool = $false
    }
}

#Run the IP Test on an Auto Generated IP Address

function IPtest($inIP) {    
    <#
        Replace NAMING SCHEME with your computer naming scheme like above when you
        changed it for the domain function.
        i.e. "CHWD*"
    #>
    Clear-Host
    $n = $inIP
    do {
        if ($script:name -like "NAMING SCHEME") {
            <#
                Replace the IP Address below with your networks IP settings.
                If you have different IP Address for different office locations
                use the commented out elseif statements like before in the join domain function.

                Example:
                "CHWD*" (Chicago Located Computer) needs an IP Address like 192.168.22.xxx
                But "PEWD*" (Peoria Located Computer) needs an IP Address of 192.168.24.xxx
            #>
            $IP = "xxx.xxx.xxx.$n"
        }
        <#
        elseif ($script:name -like "NAMING SCHEME") {
            $IP = "xxx.xxx.xxx.$n"    
        }
        elseif ($script:name -like "NAMING SCHEME") {
            $IP = "xxx.xxx.xxx.$n"    
        }
        elseif ($script:name -like "NAMING SCHEME") {
            $IP = "xxx.xxx.xxx.$n"
        }
        test-IPaddress($IP)
        if ($n -lt 254) {
            $n++
        }#>
        else {
            Write-Error "Could Not Find Available IP Address!`n Stopping..."
            Exit    
        }
    }until($Script:IPCheckBool)
    Write-Host "`nFree IP Address : $IP`n" -ForegroundColor Cyan
    return $IP
}

#Confirm the Auto Generated IP Address or get the next available IP address and set it
function AutoSearch($res) {      
    # Change the below interger to where you want to start searching for an ip address
    # For example this will start searching at xxx.xxx.xxx.111
    $v = 111
    do {
        Clear-Host
        $sel = Read-Host "Would you like to use $res ? [y] or [n]"
        switch ($sel) {
            'y' {
                set-newip($res)
                $sel = 'y'
                $script:MenuExit = 1
            }
            'n' {
                $res = IPtest($v)
                $v++
            }
        }
    }until($sel -eq 'y')  
}

#Set the IP Settings manually including the Default Gateway and DNS Servers 
#NOTE: Change the $Maskbits value to reflect your Subnet Mask
function set-manualIP($UsrIn) {
    $IP = $UsrIn
    
    Write-Host "IP Address Selected: $IP"
    $Gateway = read-host -prompt "`nEnter Default Gateway "
    $Dns1 = read-host -prompt "`nEnter 1st DNS Server "
    $Dns2 = Read-Host -Prompt "`nEnter 2nd DNS Server "
    $DNS = $Dns1 , $Dns2

    #$MaskBits = 24 # This means subnet mask = 255.255.255.0
    $MaskBits = 23 # This means subnet mask = 255.255.254.0 

    Clear-Host
    Write-Host "About to apply these Settings:`n`nIP Address: $IP`nGateway: $Gateway`nPrimary DNS Server: $Dns1`nAlternate DNS Server: $Dns2 `n" -ForegroundColor Magenta
    $zz = Read-Host "Are These Settings Correct?`n[y] | [n]"
    switch ($zz) {
        'y' { continue }
        'n' { show-IPmenu('3') }
    }
    
    $IPType = "IPv4"
    
    # Retrieve the network adapter that you want to configure
    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "up" }
    
    # Remove any existing IP, gateway from ipv4 adapter
    If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
        $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
    }
    If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
        $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
    }
    
    # Configure the IP address and default gateway
    $adapter | New-NetIPAddress `
        -AddressFamily $IPType `
        -IPAddress $IP `
        -PrefixLength $MaskBits `
        -DefaultGateway $Gateway
    
    # Configure the DNS client server IP addresses
    $adapter | Set-DnsClientServerAddress -ServerAddresses $DNS
}

#Display the Set IP Address Menu
function show-IPmenu ($opt) {
    do {
        IPmenu
        if ($opt -eq '1') {
            $selection = $opt
        }
        elseif ($opt -eq '2') {
            $selection = $opt
        }
        elseif ($opt -eq '3') {
            $selection = $opt
        }
        else {
            $selection = Read-Host -Prompt "`nPlease Make A Selection "
        }
        switch ($selection) {
            '1' {
                Clear-Host
                    # Change the below interger 110 to where you want to start searching for an ip address
                    # For example this will start searching at xxx.xxx.xxx.110
                $out = IPtest(110)
                AutoSearch($out)
            } 
            '2' {
                do {
                    Clear-Host
                    $usrip = Read-Host -Prompt "`nEnter Desired IP Address"
                        
                    test-IPaddress($usrip)
                        
                    if ($Script:IPCheckBool -eq $true) {
                        Clear-Host
                        Start-Sleep -Seconds 3
                        set-newip($usrip)
                        $script:MenuExit = 1
                        $throwaway = 1
                    }
                    else {
                        Write-Host "`nIP Address $usrip Is Not Free!`n`nTry Another IP Address`n" -ForegroundColor Red
                        Pause                            
                    }

                }until($throwaway -eq 1)
            }
            '3' {
                do {
                    Clear-Host
                    $usrman = Read-Host -Prompt "`nEnter Desired IP Address"
                        
                    test-IPaddress($usrman)
                        
                    if ($Script:IPCheckBool -eq $true) {
                        Clear-Host
                        Start-Sleep -Seconds 3
                        set-manualIP($usrman)
                        $script:MenuExit = 1
                        $throwaway = 1
                    }
                    else {
                        Write-Host "`nIP Address $usrip Is Not Free!`n`nTry Another IP Address`n" -ForegroundColor Red
                        Pause                            
                    }

                }until($throwaway -eq 1)
            }
        }
    }
    until ($selection -eq 'q' -or $script:MenuExit -eq 1)
}

#Set the IP Address based on the Computer Name
function set-newip($InputIP) {
    
    $IP = $InputIP
    
    <#
        Replace NAMING SCHEME with your computer naming scheme like above when you
        changed it for the domain function.
        i.e. "CHWD*"

        Change the values for $Gateway , $Dns1 , $Dns2 and $MaskBits to reflect your network
    #>

        #$MaskBits = 24 # This means subnet mask = 255.255.255.0
        $MaskBits = 23 # This means subnet mask = 255.255.254.0

    if ($script:name -like "NAMING SCHEME") {
        $Gateway = "DEFAULT GATEWAY"
        $Dns1 = "PRIMARY DNS SERVER IP"
        $Dns2 = "ALTERNATE DNS SERVER IP"
        $Dns = $Dns1 , $Dns2
    }
    <#
    elseif ($script:name -like "NAMING SCHEME") {
        $Gateway = "DEFAULT GATEWAY"
        $Dns1 = "PRIMARY DNS SERVER IP"
        $Dns2 = "ALTERNATE DNS SERVER IP"
        $Dns = $Dns1 , $Dns2
    }

    elseif ($script:name -like "NAMING SCHEME") {
        $Gateway = "DEFAULT GATEWAY"
        $Dns1 = "PRIMARY DNS SERVER IP"
        $Dns2 = "ALTERNATE DNS SERVER IP"
        $Dns = $Dns1 , $Dns2
    }

    elseif ($script:name -like "NAMING SCHEME") {
        $Gateway = "DEFAULT GATEWAY"
        $Dns1 = "PRIMARY DNS SERVER IP"
        $Dns2 = "ALTERNATE DNS SERVER IP"
        $Dns = $Dns1 , $Dns2
    }
    #>
    else {
        $Gateway = read-host -prompt "Enter Default Gateway "
        $Dns = read-host -prompt "Enter DNS Settings "   
    }

    Clear-Host
    Write-Host "About to apply these Settings:`n`nIP Address: $IP`nGateway: $Gateway`nPrimary DNS Server: $Dns1`nAlternate DNS Server: $Dns2 `n" -ForegroundColor Magenta
    $zz = Read-Host "Are These Settings Correct?`n[y] | [n]"
    switch ($zz) {
        'y' { continue }
        'n' { show-IPmenu('3') }
    }
    
    $IPType = "IPv4"
    
    # Retrieve the network adapter that you want to configure
    $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "up" }
    
    # Remove any existing IP, gateway from ipv4 adapter
    If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
        $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
    }
    If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
        $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
    }
    
    # Configure the IP address and default gateway
    $adapter | New-NetIPAddress `
        -AddressFamily $IPType `
        -IPAddress $IP `
        -PrefixLength $MaskBits `
        -DefaultGateway $Gateway
    
    # Configure the DNS client server IP addresses
    $adapter | Set-DnsClientServerAddress -ServerAddresses $DNS
}

#Application Installer Menu
function ApplicationMenu {
    <#
        Update the menu below to reflect what applications you want to install
    #>

    param (
        [string]$Title = 'Application Installer Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "A: Press 'A' to install All Listed Applications"
    Write-Host "1: Press '1' to install Adobe Acrobat 2020"
    Write-Host "2: Press '2' to install APPLICATION"
    Write-Host "3: Press '3' to install Firefox"
    Write-Host "4: Press '4' to install Kace Agent"
    Write-Host "5: Press '5' to install Office 365"
    Write-Host "Q: Press 'Q' to quit."
}

#Mount the Installers folder and copy them to the local machine
function get-installers {
    <#
        Change PATH TO FOLDER to the folder path of where the installers are located.
        
        **It is Highly recommended to consolidate all the installers you are going to use
        into a central location.
        
        For example below the path ends with a folder called WindowsDeployment
        
        Inside this folder is another folder called ApplicationInstallers <- that is where the installer folders are located like AdobeAcrobat 
        that would contain the setup.exe file
    #>
    Clear-Host
    Write-Host "`nMounting Application Installers Drive..."
    New-PSDrive -Name T -Root "\\FILESERVERNAME\PATH\TO FOLDER\WindowsDeployment" -Persist -PSProvider "FileSystem" -Credential $Credential
    
    Write-Host "`nCopying Installers to Local Folder..."
    & Robocopy.exe "T:\ApplicationInstallers" "C:\WinDeployApps" /mt:128 /E
}

#Installer Functions

<#
    Edit these functions or use as a template for applications you wish to install
    
    Use the KaceAgentInstall or FirefoxInstall function as an example on how to install
    an application using an MSI file.
#>
function AdobeInstall {
    Write-Host "`nInstalling Adobe "
    Start-Process "$windeployapps\AdobeAcrobat\setup.exe" -Wait
}

function KaceAgentInstall {
    #Change the AMPAGENT MSI FILE for your specific kace agent msi.
    Write-Host "`nInstalling Kace "
    Start-Process msiexec.exe "/I $windeployapps\KaceAgent\AMPAGENT MSI FILE /qn" -Wait
}

function Office365Install {
    Write-Host "`nInstalling Office365"
    Start-Process "$windeployapps\Office365\setup.exe" -ArgumentList "/configure C:\windeployapps\Office365\YOUR CONFIGUREATION.XML FILE" -Wait
}

function FirefoxInstall {
    #NOTE: This application requires a policies.json file to import the system certificates for Corporate use.
    Write-Host "`nInstalling Firefox"
    Start-Process msiexec.exe -ArgumentList "/I $windeployapps\Firefox\firefox.msi /passive" -Wait
    
    Start-Sleep -Seconds 2
    
    Start-Process firefox.exe
    
    Start-Sleep -Seconds 1
    
    Stop-Process -Name firefox

    New-Item -Path "C:\Program Files\Mozilla Firefox" -ItemType Directory -Name "distribution"

    Start-Sleep -Seconds 1

    <#
        Copies the policies.json file to the newly created distribution folder
        
        This is required for Firefox to use Enterprise Certificates for any user that logs onto the computer.
        to use this feature create a file named policies.json in the Firefox Installer Folder and make sure it
        contains the below code:

        {
        "policies": {
                "Certificates": {
                    "ImportEnterpriseRoots": true
            }
          }
        }
    
    #>
    
    # Uncomment the below line to Enable Firefox to use Enterprise Certificates
    #Copy-Item -Path "$windeployapps\Firefox\policies.json" -Destination "C:\Program Files\Mozilla Firefox\distribution"
}

#Install All Applications

#NOTE: Be sure to edit this function to reflect the Applications you want to install

function Install-All {
    Clear-Host

    <#
        Replace the Below Functions with any functions you created to install an application
        there is a 5 second pause between installs to ensure the program has finished installing
    #>

    #AdobeInstall

    Start-Sleep -Seconds 5
        
   #KaceAgentInstall
    
    Start-Sleep -Seconds 5
    
    #FirefoxInstall
    
    Start-Sleep -Seconds 5
    
    #Office365Install
}

#Display the Application Installer Menu
function show-applicationmenu {
    
    get-installers #Mounts Application Installers Drive and Copies the installers to local folder
    
    do {
        ApplicationMenu
        $selection = Read-Host "`nPlease make a selection"

        <#
            Use the below code as a template for running your application installer functions
            Replace APPLICATION FUNCTION with your application installer function
        #>
        switch ($selection) {
            '1' {
                AdobeInstall
            } 
            '2' {
                #APPLICATION FUNCTION
            } 
            '3' {
                #FirefoxInstall
            }
            '4' {
                #KaceAgentInstall
            }
            '5' {
                #Office365Install
            }
            'A' {
                Install-All
            }
        }
    }
    until ($selection -eq 'q')
}

#Ask the user if they wish to restart the Machine
function Restart-Required {
    $userRestart = Read-Host -Prompt "To finish setup a restart is required. `n`nWould you like to restart now? [Y]es [N]o "

    if ($userRestart -eq "y") {
        Restart-Computer
    }
    else {
        exit
    }
}

######Running The Script######

show-MainMenu

Remove-Item -Path $windeployapps -Recurse #Removes the folder with the copied application installers

Clear-Host

Restart-Required

######END OF SCRIPT######