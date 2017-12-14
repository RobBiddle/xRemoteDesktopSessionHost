Import-Module -Name "$PSScriptRoot\..\..\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement)) { Throw "The minimum OS requirement was not met."}
Import-Module RemoteDesktop
$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName

#######################################################################
# The Get-TargetResource cmdlet.
#######################################################################
function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [parameter(Mandatory)]
        [ValidateLength(1,15)]
        [string] $CollectionName,
        [uint32] $ActiveSessionLimitMin,
        [boolean] $AuthenticateUsingNLA,
        [boolean] $AutomaticReconnectionEnabled,
        [string] $BrokenConnectionAction,
        [string] $ClientDeviceRedirectionOptions,
        [boolean] $ClientPrinterAsDefault,
        [boolean] $ClientPrinterRedirected,
        [string] $CollectionDescription,
        [string] $ConnectionBroker = $localhost,
        [string] $CustomRdpProperty,
        [uint32] $DisconnectedSessionLimitMin,
        [string] $EncryptionLevel,
        [uint32] $IdleSessionLimitMin,
        [uint32] $MaxRedirectedMonitors,
        [boolean] $RDEasyPrintDriverEnabled,
        [string] $SecurityLayer,
        [boolean] $TemporaryFoldersDeletedOnExit,
        [string] $UserGroup
    )
    Write-Verbose "Getting currently configured RDSH Collection properties"
    $Collection = Get-RDSessionCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
    if ($Collection -ne $null) {
        $collectionGeneral = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
        $collectionClient = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -Client
        $collectionConnection = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -Connection
        $collectionSecurity = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -Security
        $collectionUserGroup = Get-RDSessionCollectionConfiguration -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -UserGroup
        @{
            "CollectionName"                 = $collectionGeneral.CollectionName;
            "ActiveSessionLimitMin"          = $collectionConnection.ActiveSessionLimitMin;
            "AuthenticateUsingNLA"           = $collectionSecurity.AuthenticateUsingNLA;
            "AutomaticReconnectionEnabled"   = $collectionConnection.AutomaticReconnectionEnabled;
            "BrokenConnectionAction"         = $collectionConnection.BrokenConnectionAction;
            "ClientDeviceRedirectionOptions" = $collectionClient.ClientDeviceRedirectionOptions;
            "ClientPrinterAsDefault"         = $collectionClient.ClientPrinterAsDefault;
            "ClientPrinterRedirected"        = $collectionClient.ClientPrinterRedirected;
            "CollectionDescription"          = $collectionGeneral.CollectionDescription;
            "CustomRdpProperty"              = $collectionGeneral.CustomRdpProperty;
            "DisconnectedSessionLimitMin"    = $collectionGeneral.DisconnectedSessionLimitMin;
            "EncryptionLevel"                = $collectionSecurity.EncryptionLevel;
            "IdleSessionLimitMin"            = $collectionConnection.IdleSessionLimitMin;
            "MaxRedirectedMonitors"          = $collectionClient.MaxRedirectedMonitors;
            "RDEasyPrintDriverEnabled"       = $collectionClient.RDEasyPrintDriverEnabled;
            "SecurityLayer"                  = $collectionSecurity.SecurityLayer;
            "TemporaryFoldersDeletedOnExit"  = $collectionConnection.TemporaryFoldersDeletedOnExit;
            "UserGroup"                      = $collectionUserGroup.UserGroup;
        }
    }

}


######################################################################## 
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [ValidateLength(1,15)]
        [string] $CollectionName,
        [uint32] $ActiveSessionLimitMin,
        [boolean] $AuthenticateUsingNLA,
        [boolean] $AutomaticReconnectionEnabled,
        [string] $BrokenConnectionAction,
        [string] $ClientDeviceRedirectionOptions,
        [boolean] $ClientPrinterAsDefault,
        [boolean] $ClientPrinterRedirected,
        [string] $CollectionDescription,
        [string] $ConnectionBroker = $localhost,
        [string] $CustomRdpProperty,
        [uint32] $DisconnectedSessionLimitMin,
        [string] $EncryptionLevel,
        [uint32] $IdleSessionLimitMin,
        [uint32] $MaxRedirectedMonitors,
        [boolean] $RDEasyPrintDriverEnabled,
        [string] $SecurityLayer,
        [boolean] $TemporaryFoldersDeletedOnExit,
        [string] $UserGroup
    )
    Write-Verbose "Setting DSC collection properties"
    $Collection = Get-RDSessionCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
    if ($Collection -eq $null) {
        Throw "Collection named $CollectionName does not exist!  Use xRDSessionCollection configuration to create the collection."
    }
    $ScriptBlock = {
        Import-Module RemoteDesktop -Force # required to suppress "The term 'Set-RDSessionCollectionConfiguration' is not recognized as the name of a cmdlet, function, script file, or operable program." error
        Set-RDSessionCollectionConfiguration @using:PSBoundParameters 
    }
    Start-Job -Name "Set-RDSessionCollectionConfiguration" -ScriptBlock $ScriptBlock | Out-Null
    Get-Job -Name "Set-RDSessionCollectionConfiguration" | Wait-Job | Out-Null
    Receive-Job -Name "Set-RDSessionCollectionConfiguration"
}


#######################################################################
# The Test-TargetResource cmdlet.
#######################################################################
function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [parameter(Mandatory)]
        [ValidateLength(1,15)]
        [string] $CollectionName,
        [uint32] $ActiveSessionLimitMin,
        [boolean] $AuthenticateUsingNLA,
        [boolean] $AutomaticReconnectionEnabled,
        [string] $BrokenConnectionAction,
        [string] $ClientDeviceRedirectionOptions,
        [boolean] $ClientPrinterAsDefault,
        [boolean] $ClientPrinterRedirected,
        [string] $CollectionDescription,
        [string] $ConnectionBroker = $localhost,
        [string] $CustomRdpProperty,
        [uint32] $DisconnectedSessionLimitMin,
        [string] $EncryptionLevel,
        [uint32] $IdleSessionLimitMin,
        [uint32] $MaxRedirectedMonitors,
        [boolean] $RDEasyPrintDriverEnabled,
        [string] $SecurityLayer,
        [boolean] $TemporaryFoldersDeletedOnExit,
        [string] $UserGroup
    )
    
    Write-Verbose "Testing DSC collection properties"
    $Collection = Get-RDSessionCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
    if ($Collection -eq $null) {
        Write-Verbose "Collection $CollectionName does not exist!"
        Return $false
    }
    $PSBoundParameters.Remove("Verbose") | out-null
    $PSBoundParameters.Remove("Debug") | out-null
    $Check = $true
    $Get = Get-TargetResource @PSBoundParameters
    $PSBoundParameters.Remove("ConnectionBroker") | out-null
    $PSBoundParameters.keys | ForEach-Object {
        if ($PSBoundParameters[$_] -ne $Get[$_]) {
            $Check = $false
        } 
    }
    $Check
}

Export-ModuleMember -Function *-TargetResource

