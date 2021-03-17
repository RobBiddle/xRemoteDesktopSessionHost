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
        [string] $CollectionName = "Tenant",
        [parameter(Mandatory)]
        [string] $DisplayName = "Calculator",
        [parameter(Mandatory)]
        [string] $FilePath = "C:\Windows\System32\calc.exe",
        [parameter(Mandatory)]
        [string] $Alias = "calc",
        [string] $ConnectionBroker = $localhost,
        [string] $FileVirtualPath,
        [string] $FolderName,
        [string] $CommandLineSetting,
        [string] $RequiredCommandLine,
        [uint32] $IconIndex,
        [string] $IconPath,
        [string[]] $UserGroups,
        [boolean] $ShowInWebAccess
    )
        Write-Verbose "Getting published RemoteApp program $DisplayName, if one exists."
        $Collection = Get-RDSessionCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker
        $remoteApp = Get-RDRemoteApp -CollectionName $Collection.CollectionName -ConnectionBroker $ConnectionBroker -DisplayName $DisplayName -Alias $Alias

        @{
        "CollectionName" = $remoteApp.CollectionName;
        "DisplayName" = $remoteApp.DisplayName;
        "FilePath" = $remoteApp.FilePath;
        "Alias" = $remoteApp.Alias;
        "FileVirtualPath" = $remoteApp.FileVirtualPath;
        "FolderName" = $remoteApp.FolderName;
        "CommandLineSetting" = $remoteApp.CommandLineSetting;
        "RequiredCommandLine" = $remoteApp.RequiredCommandLine;
        "IconIndex" = $remoteApp.IconIndex;
        "IconPath" = $remoteApp.IconPath;
        "UserGroups" = $remoteApp.UserGroups;
        "ShowInWebAccess" = $remoteApp.ShowInWebAccess;
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
        [string] $DisplayName,
        [parameter(Mandatory)]
        [string] $FilePath,
        [parameter(Mandatory)]
        [string] $Alias,
        [string] $ConnectionBroker = $localhost,
        [string] $FileVirtualPath,
        [string] $FolderName,
        [string] $CommandLineSetting,
        [string] $RequiredCommandLine,
        [uint32] $IconIndex,
        [string] $IconPath,
        [string[]] $UserGroups,
        [boolean] $ShowInWebAccess
    )
    $Collection = Get-RDSessionCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker  -ErrorAction SilentlyContinue
    if ($Collection -eq $null) {
        Throw "Collection named $CollectionName does not exist!  Use xRDSessionCollection configuration to create the collection."
    }
    if (!$(Get-RDRemoteApp -Alias $Alias)) {
        Write-Verbose "Publishing a New RemoteApp wth Alias $Alias."
        New-RDRemoteApp @PSBoundParameters
        }
    else {
        Write-Verbose "Making updates to existing RemoteApp $Alias."
        Set-RDRemoteApp @PSBoundParameters
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
        [string] $DisplayName,
        [parameter(Mandatory)]
        [string] $FilePath,
        [parameter(Mandatory)]
        [string] $Alias,
        [string] $ConnectionBroker = $localhost,
        [string] $FileVirtualPath,
        [string] $FolderName,
        [string] $CommandLineSetting,
        [string] $RequiredCommandLine,
        [uint32] $IconIndex,
        [string] $IconPath,
        [string[]] $UserGroups,
        [boolean] $ShowInWebAccess
    )
    Write-Verbose "Testing if RemoteApp is published."
    $Collection = Get-RDSessionCollection -CollectionName $CollectionName -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
    if ($Collection -eq $null) {
        Write-Verbose "Collection named $CollectionName does not exist!  Use xRDSessionCollection configuration to create the collection."
        Return $false
    }
    $PSBoundParameters.Remove("Verbose") | out-null
    $PSBoundParameters.Remove("Debug") | out-null
    $Check = $true
    
    $Get = Get-TargetResource -CollectionName $Collection.CollectionName -ConnectionBroker $ConnectionBroker -DisplayName $DisplayName -FilePath $FilePath -Alias $Alias
    $PSBoundParameters.Remove("ConnectionBroker") | out-null
    $PSBoundParameters.keys | ForEach-Object {
        if ( ($PSBoundParameters[$_] -ne $null) -and ($Get[$_] -eq $null) ) {
            $Check = $false
        }
        else {
            $Differences = Compare-Object -ReferenceObject $PSBoundParameters[$_] -DifferenceObject $Get[$_]
            if ($Differences) {
                Write-Verbose "Property $_ is NOT in the desired state."
                $Check = $false
            }
            else {
                Write-Verbose "Property $_ is in the desired state."
            }
        }

    }
    $Check
}

Export-ModuleMember -Function *-TargetResource

