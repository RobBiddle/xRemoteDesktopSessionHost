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
        $WorkspaceName
    )
    Write-Verbose "Getting RD Workspace Configuration"
    $WorkspaceConfiguration = Get-RDWorkspace -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
    
    @{
        "WorkspaceID"      = $WorkspaceConfiguration.WorkspaceID
        "WorkspaceName"     = $WorkspaceConfiguration.WorkspaceName
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
        $WorkspaceName
    )
    # Set $Global:ErrorActionPreference to Stop in order to catch errors from Set-RDWorkspace
    $OriginalErrorActionPreference = $Global:ErrorActionPreference
    $Global:ErrorActionPreference = 'Stop'
    Write-Verbose "Setting RD Workspace Name to $WorkspaceName"
    try {
        Set-RDWorkspace -Name $WorkspaceName -ConnectionBroker $ConnectionBroker
        # Set $Global:ErrorActionPreference back to original value after catching error
        $Global:ErrorActionPreference = $OriginalErrorActionPreference
    }
    catch {
        # Set $Global:ErrorActionPreference back to original value after catching error
        $Global:ErrorActionPreference = $OriginalErrorActionPreference
        Write-Verbose "Set-RDWorkspace threw an error.  Switcihng to WMI method"
        $WkspObjCol = get-wmiobject -ComputerName $ConnectionBroker `
            -namespace "root\cimv2\terminalservices" `
            -query "Select * From Win32_Workspace" `
            -Authentication PacketPrivacy -ErrorAction Stop

        foreach ($WkspObj in $WkspObjCol) {
            $WkspObj.Name = $WorkspaceName
            $WkspObj.Put()
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
        $WorkspaceName
    )
    Write-Verbose "Checking RD Workspace Configuration."
    $PSBoundParameters.Remove("Verbose") | out-null
    $PSBoundParameters.Remove("Debug") | out-null
    $Check = $true
    $Get = Get-TargetResource @PSBoundParameters
    $PSBoundParameters.Remove("ConnectionBroker") | out-null
    $PSBoundParameters.keys | ForEach-Object {
        if (-NOT ($PSBoundParameters[$_] -imatch $Get[$_])) {
            $Check = $false
        } 
    }

    $Check
}

Export-ModuleMember -Function *-TargetResource
