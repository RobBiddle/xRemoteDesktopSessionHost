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
    Write-Verbose "Checking RDSH collection."
    $Get = Get-TargetResource @PSBoundParameters
    if ($Get.CollectionName -ine $CollectionName) {
        Write-Verbose "Creating a new RDSH collection."
        New-RDSessionCollection @PSBoundParameters
    }
    else {
        Write-Verbose "Modifying existing RDSH collection."
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
    Write-Verbose "Checking RDSH collection."
    $PSBoundParameters.Remove("Verbose") | out-null
    $PSBoundParameters.Remove("Debug") | out-null
    $Check = $true
    $Get = Get-TargetResource @PSBoundParameters
    $PSBoundParameters.Remove("ConnectionBroker") | out-null
    $PSBoundParameters.Remove("CollectionDescription") | out-null
    $PSBoundParameters.keys | ForEach-Object {
        if (-NOT ($Get[$_] -imatch $PSBoundParameters[$_])) {
            $Check = $false
        }
    }
    $Check
}


Export-ModuleMember -Function *-TargetResource

