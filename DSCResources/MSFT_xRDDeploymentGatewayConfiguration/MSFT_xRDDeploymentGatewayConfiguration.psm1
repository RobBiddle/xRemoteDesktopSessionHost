Import-Module -Name "$PSScriptRoot\..\..\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement)) { Throw "The minimum OS requirement was not met."}
Import-Module RemoteDesktop -Force -Verbose:$false
$localhost = [System.Net.Dns]::GetHostByName((hostname)).HostName

#######################################################################
# The Get-TargetResource cmdlet.
#######################################################################
function Get-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (    
        [parameter(Mandatory)]
        [string]
        $GatewayExternalFqdn,

        [parameter(Mandatory)]
        [ValidateSet("DoNotUse", "Custom", "Automatic")]        
        [string]
        $GatewayMode,

        [string]
        $ConnectionBroker = $localhost,

        [ValidateSet("Password", "Smartcard", "AllowUserToSelectDuringConnection")]        
        [string]
        $LogonMethod,

        [boolean]
        $BypassLocal,

        [boolean]
        $UseCachedCredentials
    )
    Write-Verbose "Getting RD Deployment Gateway Configuration"
    $GatewayConfiguration = Get-RDDeploymentGatewayConfiguration -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
    @{
        "GatewayMode"          = $GatewayConfiguration.GatewayMode
        "GatewayExternalFqdn"  = $GatewayConfiguration.GatewayExternalFqdn
        "LogonMethod"          = $GatewayConfiguration.LogonMethod
        "BypassLocal"          = $GatewayConfiguration.BypassLocal
        "UseCachedCredentials" = $GatewayConfiguration.UseCachedCredentials
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
        [string]
        $GatewayExternalFqdn,

        [parameter(Mandatory)]
        [ValidateSet("DoNotUse", "Custom", "Automatic")]        
        [string]
        $GatewayMode,

        [string]
        $ConnectionBroker = $localhost,

        [ValidateSet("Password", "Smartcard", "AllowUserToSelectDuringConnection")]        
        [string]
        $LogonMethod,
        
        [boolean]
        $BypassLocal,

        [boolean]
        $UseCachedCredentials
    )

    Write-Verbose "Setting RD Deployment Gateway Configuration."
    Set-RDDeploymentGatewayConfiguration @PSBoundParameters -Force -ErrorAction Continue
}


#######################################################################
# The Test-TargetResource cmdlet.
#######################################################################
function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (    
        [parameter(Mandatory)]
        [string]
        $GatewayExternalFqdn,
  
        [parameter(Mandatory)]
        [ValidateSet("DoNotUse", "Custom", "Automatic")]        
        [string]
        $GatewayMode,
  
        [string]
        $ConnectionBroker = $localhost,
  
        [ValidateSet("Password", "Smartcard", "AllowUserToSelectDuringConnection")]        
        [string]
        $LogonMethod,
          
        [boolean]
        $BypassLocal,
  
        [boolean]
        $UseCachedCredentials
    )
    Write-Verbose "Checking RD Deployment Gateway Configuration."
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
