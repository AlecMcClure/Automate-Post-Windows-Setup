# Automate-Post-Windows-Setup
# Post Windows Setup Script

This script is a template that is designed to help automate tasks that are typically performed on a new Windows installation/image.

Such as:

- Set A Static IP Address
- Join A Domain
- Install Some Applications

<br/>

## Who is this script for?
\
This script is intended for anyone who is responsible for setting up physical computers on a domain.
\
<br/>
## Warning:
- This script was written to accomodate an environment using Static IP Addresses. 

- It has not been tested on an environment using DHCP.

\
This script also presumes you use a Computer Naming Scheme. 

For Example:

>A computer name for a Chicago Laptop running Windows 10 would have a name like: <br/>CHWD10-TESTLT

<br/>

**If you are using DHCP or do not use a Computer Naming Scheme then this script may not work**

<br/>

# Please Follow These Instructions Carefully

### **1. Get Domain Admin Account**

Change `$Credential = Get-Credential "DOMAIN\ADMIN ACCOUNT"` on **Line 30** to your Domain and Domain Administrator Username

For Example: 
> `$Credential = Get-Credential "CONTOSO\Administrator"`

<br/>

### **2. Get Domain**

Inside the `join-domain` function on **Line 183**  change `$Domain = "YOUR DOMAIN"` to your Fully Qualified Domain Name.

For Example:
>  `$Domain = "example.contoso.com"`

<br/>

### **3. Set Computer Naming Scheme For Joining Domain**

On **Line 199** Change `if ($script:name -like "NAMING SCHEME")` to your Computer Naming Scheme.

For example:

> A computer with the name: CHWD10-TESTLT \
    Would look like this: `if ($script:name -like "CHWD*")`

<br/>

If you have multiple locations Uncomment the elseif statements to specify your
other names 

For example:
> A computer in New York with the name: NYWD10-TESTLT \
Would look like this: `elseif ($script:name -like "NYWD*")`

<br/>

### **4. Get Domain Controller/s**
Next on **Line 202** change `$Server = "DOMAIN CONTROLLER"` to name of your locations Domain Controller.

For Example:

> `$Server = MYDC01`

Do the same for any elseif statements you used for your other Computer Name Schemes

<br/>

### **5. Get OU Computer Path/s**
On **Line 217** replace the `OU COMPUTER PATH` with the OU Path for your computer accounts in Active Directory.

For Example if your domain is `'example.contoso.com'` and your computer OU is under another OU called Seattle 

`'OU COMPUTER PATH'` would look like this:
> `'OU=Seattle_Workstation,OU=Seattle,DC=example,DC=contoso,DC=com'`

<br/>
Do the same for any elseif statements you used for your other Computer Name Schemes

<br/>

### **6. Set Computer Naming Scheme For Finding IP Address**

On **Line 317** replace `'NAMING SCHEME'` with your Computer Naming Scheme. 

**Like in Step 3**

Do the same for any elseif statements you use.

<br/>

### **7. Set The Starting IP Address**
On **Line 327** replace `$IP = "xxx.xxx.xxx.$n"`with your networks IP settings.


If you have different IP Address for different office locations use the commented out elseif statements.

**Like in Step 3**

For Example:

> "CHWD*" (Chicago Based Computer) would be: <br/> 
`$IP = "192.168.22.$n"` <br/><br/>
"NYWD*" (New York Based Computer) would be: <br/>
`$IP = "192.168.24.$n"`

<br/>

### **8. Set the Starting Octet [Optional]**
Currently if you choose to use the Auto Search for Free IP option it starts at xxx.xxx.xxx.110 
<br/>

If you wish to change this then update the numbers for `$v = 111 ` on **Line 356** and `$out = IPtest(110)` on **Line 441** to where you want to start the search from. 

Note that `$v = 111` is 1 higher than `$out = IPtest(110)` make sure you update it accordingly for your starting number.

<br/>

### **9. Setup The Auto IP Search Function**
On **Line 505** change `$MaskBits = 23` to reflect what subnet mask you are using on your network

**Like in Step 3** we will be using more if/elseif statements using the Computer Naming Scheme. On **Line 507** update `"NAMING SCHEME"` to your Computer Naming Scheme.

On **Lines 507 - 510** update the variables to reflect your networks Default Gateway and DNS Servers.

Do the same for any elseif statements you use.

<br/>

### **10. Update Application Menu and Get Application Installers**
On **Line 573** update the menu that lists the applications you wish to install.

Change `PATH TO FOLDER` on **Line 608** to the folder path of where the installers are located.
        
**It is Highly recommended to consolidate all the installers you are going to useinto a central location.**

***See ApplicationInstallers.docx for examples***

<br/>

### **11. Application Installer Functions**
Use the following as a template to create Application Installer Functions

If using MSI file: <br/>
> `function ApplicationNameInstall {` \
`Write-Host "Installing ApplicationName"` \
`Start-Process msiexec.exe "/I $windeployapps\APPLICATION NAME FOLDER\Application.msi /qn" -wait` \
`}`

If using EXE file:
> `function ApplicationNameInstall {` \
`Write-Host "Installing ApplicationName"` \
`Start-Process "$windeployapps\APPLICATION NAME FOLDER\Application.exe" -wait` \
`}`

<br/>

### **12. Update `Install-All` Function**
On **Line 680** Update/Change the Commented Application Installer Functions to any functions you created in **Step 11**

Notice there is a 5 second delay between Installs, this is to ensure the previous installer has finished.

<br/>

### **13. Update Application Menu**
On **Line 704** use the code as a template for updating/creating your Application Menu 

<br/>

## **Testing**

When running this script for testing purposes ensure that your Powershell Execution policy is set to either Bypass. 

You can get this by opening Powershell as Admin and running `Get-ExecutionPolicy` if your Execution Policy is set to something other than Bypass use the command `Set-ExecutionPolicy Bypass` to update it.

<br/>

**Quick Note:** \
For the script to work you will need to run it as Administrator and that `Get-ExecutionPolicy` reports Bypass

Remember to change the Execution Policy back to either AllSigned or Restricted using `Set-ExecutionPolicy Restricted` after the script has finished.

<br/>

# Questions and Assistance
If you have any Questions/Issues or need some Assistance with debugging the script Use the Issues Tab in Github and report it. I will try to provide help when/where I can.

If you have any feedback for this script please also submit and Issue with the tag Feedback: in the title.

Thank you!

