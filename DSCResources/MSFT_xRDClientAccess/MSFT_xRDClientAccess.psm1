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
        [string]
        $ConnectionBroker = $localhost,
        [parameter(Mandatory)]
        [string]
        $ClientAccessName
    )
    Write-Verbose "Getting RD ClientAccess Configuration"
    [RegEx]$Pattern = 'full address:s:.*'
    $RdpFileContents = (get-wmiobject -ComputerName $ConnectionBroker -Namespace root\cimv2\terminalservices -Class Win32_RDCentralPublishedRemoteDesktop).RDPFileContents
    $CurrentClientAccessName = ($Pattern.Match($RdpFileContents)).Value -split ':' | Select-Object -Last 1
    Write-Verbose "Current Client Access Name is $CurrentClientAccessName"
    @{
        "ClientAccessName" = $CurrentClientAccessName
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
        [string]
        $ConnectionBroker = $localhost,
        [parameter(Mandatory)]
        [string]
        $ClientAccessName
    )
    $CurrentClientAccessName = (Get-TargetResource @PSBoundParameters).ClientAccessName
    Write-Verbose "Set-TargetResource"
    Write-Verbose "Set-TargetResource: Current Client Access Name is $CurrentClientAccessName"
    if (-NOT ($CurrentClientAccessName -imatch $ClientAccessName) ) {
        Write-Verbose "Setting Client Access Name to $ClientAccessName via Set-RDClientAccessName"
        try {
            # Set $Global:ErrorActionPreference to Stop in order to catch errors from Set-RDClientAccessName
            $OriginalErrorActionPreference = $Global:ErrorActionPreference
            $Global:ErrorActionPreference = 'Stop'
            Set-RDClientAccessName -ConnectionBroker $ConnectionBroker -ClientAccessName $ClientAccessName
            # Set $Global:ErrorActionPreference back to original value
            $Global:ErrorActionPreference = $OriginalErrorActionPreference
        }
        catch {
            $ErrorMessage = $_.Exception.Message
            # Set $Global:ErrorActionPreference back to original value after catching error
            $Global:ErrorActionPreference = $OriginalErrorActionPreference
            Write-Verbose "Error using Set-RDClientAccessName... Error was: $ErrorMessage"
            Write-Verbose "Setting Client Access Name Using WMI"
            $WmiRDDeploymentSettings = new-object Management.ManagementClass "\\.\root\cimv2\rdms:Win32_RDMSDeploymentSettings"
            $CurrentClientAccessNameFromWMI = $WmiRDDeploymentSettings.GetStringProperty("DeploymentRedirectorServer").Value
            if ($CurrentClientAccessName -imatch $CurrentClientAccessNameFromWMI) {
                $WmiRDDeploymentSettings.SetStringProperty("DeploymentRedirectorServer", $ClientAccessName).ReturnValue
            }
            
        }
    }

}


#######################################################################
# The Test-TargetResource cmdlet.
#######################################################################
function Test-TargetResource {
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (    
        [string]
        $ConnectionBroker = $localhost,
        [parameter(Mandatory)]
        [string]
        $ClientAccessName
    )
    Write-Verbose "Checking RD ClientAccess Configuration."
    $CurrentClientAccessName = (Get-TargetResource @PSBoundParameters).ClientAccessName
    ($CurrentClientAccessName -imatch $ClientAccessName)
}

Export-ModuleMember -Function *-TargetResource
