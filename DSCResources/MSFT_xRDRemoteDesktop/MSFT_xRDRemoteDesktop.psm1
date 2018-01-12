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
        [ValidateLength(1, 15)]
        [string] $CollectionName,
        [boolean] $ShowInWebAccess = $false,
        [string] $ConnectionBroker = $localhost
    )
    Write-Verbose "Getting published Remote Desktop from Collection $CollectionName, if one exists."
    $Collection = Get-RDSessionCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
    if ($Collection -eq $null) {
        Throw "Collection named $CollectionName does not exist!  Use xRDSessionCollection configuration to create the collection."
    }
    $RemoteDesktop = Get-RDRemoteDesktop -ConnectionBroker $ConnectionBroker | Where-Object CollectionName -ieq $CollectionName
    @{
        "CollectionName"  = $RemoteDesktop.CollectionName;
        "ShowInWebAccess" = $RemoteDesktop.ShowInWebAccess;
    }
}


######################################################################## 
# The Set-TargetResource cmdlet.
########################################################################
function Set-TargetResource {
    [CmdletBinding()]
    param
    (
        [parameter(Mandatory)]
        [ValidateLength(1, 15)]
        [string] $CollectionName,
        [boolean] $ShowInWebAccess = $false,
        [string] $ConnectionBroker = $localhost
    )
    Write-Verbose "Making updates to Remote Desktop"
    $Collection = Get-RDSessionCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
    if ($Collection -eq $null) {
        Throw "Collection named $CollectionName does not exist!  Use xRDSessionCollection configuration to create the collection."
    }
    $ScriptBlock = {
        Import-Module RemoteDesktop -Force # required to suppress "The term 'Set-RDRemoteDesktop' is not recognized as the name of a cmdlet, function, script file, or operable program." error
        Set-RDRemoteDesktop @using:PSBoundParameters -Force -Confirm:$false -ErrorAction SilentlyContinue
    }
    # Job required to suppress "PowerShell Desired State Configuration does not support execution of commands in an interactive mode."
    Start-Job -Name "Set-RDRemoteDesktop" -ScriptBlock $ScriptBlock | Out-Null
    Get-Job -Name "Set-RDRemoteDesktop" | Wait-Job | Out-Null
    Receive-Job -Name "Set-RDRemoteDesktop"
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
        [ValidateLength(1, 15)]
        [string] $CollectionName,
        [boolean] $ShowInWebAccess = $false,
        [string] $ConnectionBroker = $localhost
    )
    Write-Verbose "Testing if Remote Desktop is published."
    $Collection = Get-RDSessionCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
    if ($Collection -eq $null) {
        Write-Verbose "Collection named $CollectionName does not exist!  Use xRDSessionCollection configuration to create the collection."
        Return $false
    }
    $PSBoundParameters.Remove("Verbose") | out-null
    $PSBoundParameters.Remove("Debug") | out-null
    $Check = $true
    $Get = Get-TargetResource -CollectionName $Collection.CollectionName
    $PSBoundParameters.Remove("ConnectionBroker") | out-null
    $PSBoundParameters.keys | ForEach-Object {
        if ($PSBoundParameters[$_] -ne $Get[$_]) {
            $Check = $false
        } 
    }
    $Check
}

Export-ModuleMember -Function *-TargetResource

