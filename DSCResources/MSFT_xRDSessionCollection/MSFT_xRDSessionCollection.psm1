Import-Module -Name "$PSScriptRoot\..\..\xRemoteDesktopSessionHostCommon.psm1"
if (!(Test-xRemoteDesktopSessionHostOsRequirement)) { Throw "The minimum OS requirement was not met."}
Import-Module RemoteDesktop -Force -Verbose:$false
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
        [parameter(Mandatory)]
        [string] $SessionHost,
        [string] $CollectionDescription,
        [string] $ConnectionBroker = $localhost
    )
    Write-Verbose "Getting information about RDSH collection."
    $Collection = Get-RDSessionCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
    if ($Collection -eq $null) {
        Write-Verbose "Collection $CollectionName does not exist!"
        Return $false
    }
    @{
        "CollectionName"        = $Collection.CollectionName;
        "CollectionDescription" = $Collection.CollectionDescription
        "SessionHost"           = (Get-RDSessionHost -CollectionName $Collection.CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue).SessionHost
        "ConnectionBroker"      = $ConnectionBroker
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
        [parameter(Mandatory)]
        [string] $SessionHost,
        [string] $CollectionDescription,
        [string] $ConnectionBroker = $localhost
    )
    Write-Verbose "Creating a new RDSH collection."
    if ($localhost -eq $ConnectionBroker) {
        New-RDSessionCollection @PSBoundParameters
        }
    else {
        $PSBoundParameters.Remove("CollectionDescription")
        Add-RDSessionHost @PSBoundParameters
        }
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
        [parameter(Mandatory)]
        [string] $SessionHost,
        [string] $CollectionDescription,
        [string] $ConnectionBroker = $localhost
    )
    Write-Verbose "Checking for existance of RDSH collection."
    (Get-TargetResource @PSBoundParameters).CollectionName -ieq $CollectionName
}


Export-ModuleMember -Function *-TargetResource

