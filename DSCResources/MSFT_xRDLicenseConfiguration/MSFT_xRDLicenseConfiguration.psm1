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
        [string[]]
        $LicenseServer,

        [parameter(Mandatory)]
        [ValidateSet("PerUser", "PerDevice", "NotConfigured")]        
        [string]
        $Mode,

        [string]
        $ConnectionBroker = $localhost
    )
    Write-Verbose "Getting RD License Configuration"
    $LicenseConfiguration = Get-RDLicenseConfiguration -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
    @{
        "LicenseServer" = $LicenseConfiguration.LicenseServer
        "Mode"          = $LicenseConfiguration.Mode
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
        [string[]]
        $LicenseServer,

        [parameter(Mandatory)]
        [ValidateSet("PerUser", "PerDevice", "NotConfigured")]        
        [string]
        $Mode,

        [string]
        $ConnectionBroker = $localhost
    )

    Write-Verbose "Setting RD License Configuration."
    Set-RDLicenseConfiguration @PSBoundParameters -ErrorAction Continue
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
        [string[]]
        $LicenseServer,
  
        [parameter(Mandatory)]
        [ValidateSet("PerUser", "PerDevice", "NotConfigured")]        
        [string]
        $Mode,
  
        [string]
        $ConnectionBroker = $localhost
    )
    Write-Verbose "Checking RD License Configuration."
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
