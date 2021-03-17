[![Build status](https://ci.appveyor.com/api/projects/status/ly6w6vaavkshrpg8/branch/master?svg=true)](https://ci.appveyor.com/project/PowerShell/xremotedesktopsessionhost/branch/master)

# xRemoteDesktopSessionHost

The **xRemoteDesktopSessionHost** module contains the **xRDSessionDeployment**, **xRDSessionCollection**, **xRDSessionCollectionConfiguration**, and **xRDRemoteApp** resources, allowing creation and configuration of a Remote Desktop Session Host (RDSH) instance.


This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Contributing
Please check out common DSC Resources [contributing guidelines](https://github.com/PowerShell/DscResource.Kit/blob/master/CONTRIBUTING.md).


## Resources

* **xRDSessionDeployment** creates and configures a deployment in RDSH. 
* **xRDSessionCollection** creates an RDSH collection.
* **xRDSessionCollectionConfiguration** configures an RDSH collection.
* **xRDRemoteApp** publishes applications for your RDSH collection.

### xRDSessionDeployment

* **SessionHost**: Specifies the FQDN of a servers to host the RD Session Host role service.
* **ConnectionBroker**: The FQDN of a server to host the RD Connection Broker role service.
* **WebAccessServer**: The FQDN of a server to host the RD Web Access role service.
* **GatewayExternalFqdn**: Specifies the External FQDN of the RD Gateway.
* **GatewayServer**: Specifies the FQDN of a server to host the RD Gateway role service.

### xRDSessionCollection

* **CollectionName**: Specifies a name for the session collection
* **SessionHost**: Specifies a RD Session Host server to include in the session collection.
* **CollectionDescription**: A description for the collection.
* **ConnectionBroker**: The Remote Desktop Connection Broker (RD Connection Broker) server for a Remote Desktop deployment.

### xRDSessionCollectionConfiguration

* **CollectionName**: Specifies the name for the session collection.
* **ActiveSessionLimitMin**: Specifies the maximum time, in minutes, an active session runs.
After this period, the RD Session Host server ends the session.
* **AuthenticateUsingNLA**: Indicates whether to use Network Level Authentication (NLA).
If this value is $True, Remote Desktop uses NLA to authenticate a user before the user sees a logon screen.
* **AutomaticReconnectionEnabled**: Indicates whether the Remote Desktop client attempts to reconnect after a connection interruption.
* **BrokenConnectionAction**: Specifies an action for an RD Session Host server to take after a connection interruption.
* **ClientDeviceRedirectionOptions**: Specifies a type of client device to be redirected to an RD Session Host server in this session collection.
* **ClientPrinterAsDefault**: Indicates whether to use the client printer or server printer as the default printer.
If this value is $True, use the client printer as default.
If this value is $False, use the server as default.
* **ClientPrinterRedirected**: Indicates whether to use client printer redirection, which routes print jobs from the Remote Desktop session to a printer attached to the client computer.
* **CollectionDescription**: Specifies a description of the session collection.
* **ConnectionBroker**: Specifies the Remote Desktop Connection Broker (RD Connection Broker) server for a Remote Desktop deployment.
* **CustomRdpProperty**: Specifies Remote Desktop Protocol (RDP) settings to include in the .rdp files for all Windows Server 2012 RemoteApp programs and remote desktops published in this collection.
* **DisconnectedSessionLimitMin**: Specifies a length of time, in minutes.
After client disconnection from a session for this period, the RD Session Host ends the session.
* **EncryptionLevel**: Specifies the level of data encryption used for a Remote Desktop session.
* **IdleSessionLimitMin**: Specifies the length of time, in minutes, to wait before an RD Session Host logs off or disconnects an idle session.
* The BrokenConnectionAction parameter determines whether to log off or disconnect.
* **MaxRedirectedMonitors**: Specifies the maximum number of client monitors that an RD Session Host server can redirect to a remote session.
The maximum value for this parameter is 16.
* **RDEasyPrintDriverEnabled**: Specifies whether to enable the Remote Desktop Easy Print driver.
* **SecurityLayer**: Specifies which security protocol to use.
* **TemporaryFoldersDeletedOnExit**: Whether to delete temporary folders from the RD Session Host server for a disconnected session.
* **UserGroup**: Specifies a domain group authorized to connect to the RD Session Host servers in a session collection.

### xRDRemoteApp 

* **Alias**: Specifies an alias for the RemoteApp program.
* **CollectionName**: Specifies the name of the personal virtual desktop collection or session collection.
The cmdlet publishes the RemoteApp program to this collection.
* **DisplayName**: Specifies a name to display to users for the RemoteApp program.
* **FilePath**: Specifies a path for the executable file for the application.
Note: Do not include any environment variables.
* **FileVirtualPath**: Specifies a path for the application executable file.
This path resolves to the same location as the value of the FilePath parameter, but it can include environment variables.
* **FolderName**: Specifies the name of the folder that the RemoteApp program appears in on the Remote Desktop Web Access (RD Web Access) webpage and in the Start menu for subscribed RemoteApp and Desktop Connections.
* **CommandLineSetting**: Specifies whether the RemoteApp program accepts command-line arguments from the client at connection time.
* **RequiredCommandLine**: Specifies a string that contains command-line arguments that the client can use at connection time with the RemoteApp program.
* **IconIndex**: Specifies the index within the icon file (specified by the IconPath parameter) where the RemoteApp program's icon can be found.
* **IconPath**: Specifies the path to a file containing the icon to display for the RemoteApp program identified by the Alias parameter.
* **UserGroups**: Specifies a domain group that can view the RemoteApp in RD Web Access, and in RemoteApp and Desktop Connections.
To allow all users to see a RemoteApp program, provide a value of Null.
* **ShowInWebAccess**: Specifies whether to show the RemoteApp program in the RD Web Access server, and in RemoteApp and Desktop Connections that the user subscribes to.

### xRDRemoteDesktop

* **CollectionName**: Specifies the name of the personal virtual desktop collection or session collection.
* **ShowInWebAccess**: Determines if the RemoteDesktop connection is shown by the RD Web Access Server.
* **ConnectionBroker**: The FQDN of a server to host the RD Connection Broker role service.

### xRDDeploymentGatewayConfiguration

* **GatewayExternalFqdn**: Specifies the External FQDN of the RD Gateway.
* **GatewayMode**: Specifies the RD Gateway usage mode.
* **LogonMethod**: Specifies the LogonMethod to use for RD Gateway Authentication.
* **ConnectionBroker**: The FQDN of a server to host the RD Connection Broker role service.
* **BypassLocal**: Indicates whether authorized remote users bypass the RD Gateway server for local connections. By default, the value of this parameter is $False.
* **UseCachedCredentials**: Indicates whether or not remote users can use RD Gateway access credentials to authenticate access to the remote computer.

### xRDLicenseConfiguration

* **LicenseServer**: Specifies the FQDN of the RD Licensing server to configure.
* **Mode**: Specifies the licensing mode to configure for the deployment. Valid values are PerUser, PerDevice, and NotConfigured.
* **ConnectionBroker**: The FQDN of a server to host the RD Connection Broker role service.

### xRDCertificate

* **Role**: Specifies the RD Role associated with this Certificate.
* **Thumbprint**: Specifies the Thumbprint of the Certificate.
* **ConnectionBroker**: The FQDN of a server to host the RD Connection Broker role service.

### xRDClientAccess

* **ClientAccessName**: Specifies a DNS name for clients to use to connect to a Remote Desktop deployment.
* **ConnectionBroker**: The FQDN of a server to host the RD Connection Broker role service.

### xRDWorkspace

* **WorkspaceName**: Specifies the RD Workspace Name.
* **ConnectionBroker**: The FQDN of a server to host the RD Connection Broker role service.

## Versions

### Unreleased
* Additions/Modifications from: RobBiddle
    * Added **xRDCertificate** DSC Resource
    * Added **xRDClientAccess** DSC Resource
    * Added **xRDDeploymentGatewayConfiguration** DSC Resource
    * Added **xRDLicenseConfiguration** DSC Resource
    * Added **xRDRemoteDesktop** DSC Resource
    * Added **xRDWorkspace** DSC Resource
    * Modified **xRDSessionDeployment** DSC Resource to add the ability to confiugre a Remote Desktop Gateway
    * Modified **xRDRemoteApp** to accept an array of UserGroups
    * Modified **xRDSessionCollectionConfiguration** to accept array for UserGroup
    * Most Get cmdlet calls in existing DSC Resources have been refactored to specify ConnectionBroker and/or CollectionName so as to constrain changes to only named Collections/Deployments/RemoteApps.
    * This DSC Resource module now allows works when splitting the deployment of RD Roles accross multiple systems
    * This DSC Resource module will now ADD to an existing deployment if necessary 


### 1.4.0.0
* Updated CollectionName parameter to validate length between 1 and 15 characters, and added tests to verify.

### 1.3.0.0
* Converted appveyor.yml to install Pester from PSGallery instead of from Chocolatey.

### 1.2.0.0

*  Fixed an issue with version checks where OS version greater than 9 would fail (Windows 10/Server 2016)

### 1.1.0.0

* Fixed encoding

### 1.0.1

### 1.0.0.0

* Initial release with the following resources 
    * **xRDSessionDeployment**
    * **xRDSessionCollection**
    * **xRDSessionCollectionConfiguration**
    * **xRDRemoteApp**


    
## Examples

### End to End  
 
```powershell
param (
[string]$brokerFQDN,
[string]$webFQDN,
[string]$collectionName,
[string]$collectionDescription
)

$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName

if (!$collectionName) {$collectionName = "Tenant Jump Box"}
if (!$collectionDescription) {$collectionDescription = "Remote Desktop instance for accessing an isolated network environment."}

Configuration RemoteDesktopSessionHost
{
    param
    (

        # Connection Broker Name
        [Parameter(Mandatory)]
        [String]$collectionName,

        # Connection Broker Description
        [Parameter(Mandatory)]
        [String]$collectionDescription,

        # Connection Broker Node Name
        [String]$connectionBroker,

        # Web Access Node Name
        [String]$webAccessServer
    )
    Import-DscResource -Module xRemoteDesktopSessionHost
    if (!$connectionBroker) {$connectionBroker = $localhost}
    if (!$connectionWebAccessServer) {$webAccessServer = $localhost}

    Node "localhost"
    {

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        WindowsFeature Remote-Desktop-Services
        {
            Ensure = "Present"
            Name = "Remote-Desktop-Services"
        }

        WindowsFeature RDS-RD-Server
        {
            Ensure = "Present"
            Name = "RDS-RD-Server"
        }

        WindowsFeature Desktop-Experience
        {
            Ensure = "Present"
            Name = "Desktop-Experience"
        }

        WindowsFeature RSAT-RDS-Tools
        {
            Ensure = "Present"
            Name = "RSAT-RDS-Tools"
            IncludeAllSubFeature = $true
        }

        if ($localhost -eq $connectionBroker) {
            WindowsFeature RDS-Connection-Broker
            {
                Ensure = "Present"
                Name = "RDS-Connection-Broker"
            }
        }

        if ($localhost -eq $webAccessServer) {
            WindowsFeature RDS-Web-Access
            {
                Ensure = "Present"
                Name = "RDS-Web-Access"
            }
        }

        WindowsFeature RDS-Licensing
        {
            Ensure = "Present"
            Name = "RDS-Licensing"
        }

        xRDSessionDeployment Deployment
        {
            SessionHost = $localhost
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}
            WebAccessServer = if ($WebAccessServer) {$WebAccessServer} else {$localhost}
            DependsOn = "[WindowsFeature]Remote-Desktop-Services", "[WindowsFeature]RDS-RD-Server"
        }

        xRDSessionCollection Collection
        {
            CollectionName = $collectionName
            CollectionDescription = $collectionDescription
            SessionHost = $localhost
            ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}
            DependsOn = "[xRDSessionDeployment]Deployment"
        }
        xRDSessionCollectionConfiguration CollectionConfiguration
        {
        CollectionName = $collectionName
        CollectionDescription = $collectionDescription
        ConnectionBroker = if ($ConnectionBroker) {$ConnectionBroker} else {$localhost}        
        TemporaryFoldersDeletedOnExit = $false
        SecurityLayer = "SSL"
        DependsOn = "[xRDSessionCollection]Collection"
        }
        xRDRemoteApp Calc
        {
        CollectionName = $collectionName
        DisplayName = "Calculator"
        FilePath = "C:\Windows\System32\calc.exe"
        Alias = "calc"
        DependsOn = "[xRDSessionCollection]Collection"
        }
        xRDRemoteApp Mstsc
        {
        CollectionName = $collectionName
        DisplayName = "Remote Desktop"
        FilePath = "C:\Windows\System32\mstsc.exe"
        Alias = "mstsc"
        DependsOn = "[xRDSessionCollection]Collection"
        }
    }
}

write-verbose "Creating configuration with parameter values:"
write-verbose "Collection Name: $collectionName"
write-verbose "Collection Description: $collectionDescription"
write-verbose "Connection Broker: $brokerFQDN"
write-verbose "Web Access Server: $webFQDN"

RemoteDesktopSessionHost -collectionName $collectionName -collectionDescription $collectionDescription -connectionBroker $brokerFQDN -webAccessServer $webFQDN -OutputPath .\RDSDSC\

Set-DscLocalConfigurationManager -verbose -path .\RDSDSC\

Start-DscConfiguration -wait -force -verbose -path .\RDSDSC\
```
