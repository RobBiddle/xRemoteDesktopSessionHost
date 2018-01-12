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
        [string] $SessionHost,
        [string] $ConnectionBroker = $localhost,
        [parameter(Mandatory)]
        [string] $WebAccessServer,
        [string] $GatewayExternalFqdn,
        [string] $GatewayServer
    )
    Write-Verbose "Getting list of RD Server roles."
        $Deployed = Get-RDServer -ConnectionBroker $ConnectionBroker -ErrorAction SilentlyContinue
        @{
        "SessionHost" = $Deployed | Where-Object Roles -contains "RDS-RD-SERVER" | ForEach-Object Server;
        "ConnectionBroker" = $Deployed | Where-Object Roles -contains "RDS-CONNECTION-BROKER" | ForEach-Object Server;
        "WebAccessServer" = $Deployed | Where-Object Roles -contains "RDS-WEB-ACCESS" | ForEach-Object Server;
        "GatewayServer" = $Deployed | Where-Object Roles -contains "RDS-GATEWAY" | ForEach-Object Server;
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
        [string] $SessionHost,
        [string] $ConnectionBroker = $localhost,
        [parameter(Mandatory)]
        [string] $WebAccessServer,
        [string] $GatewayExternalFqdn,
        [string] $GatewayServer
    )
    try {
        Write-Verbose "Initiating new RDSH deployment."
        $SessionDeploymentParameters = $PSBoundParameters | Where-Object Keys -NotLike "GatewayServer"
        New-RDSessionDeployment @SessionDeploymentParameters
        if ($GatewayServer) {
            Add-RDServer -Server $GatewayServer -ConnectionBroker $ConnectionBroker -Role 'RDS-GATEWAY'
        }
    }
    catch {
        Write-Verbose "Adding server to Remote Desktop deployment."

        Write-Verbose "Checking SessionHost Deployment."
        if((Get-TargetResource @PSBoundParameters).SessionHost -ieq $SessionHost){
            Write-Verbose "SessionHost already deployed"
        }
        else {
            Write-Verbose "Adding New SessionHost Deployment"
            Add-RDServer -Server $SessionHost -ConnectionBroker $ConnectionBroker -Role 'RDS-RD-SERVER'
        }

        Write-Verbose "Checking ConnectionBroker Deployment."
        if((Get-TargetResource @PSBoundParameters).ConnectionBroker -ieq $ConnectionBroker){
            Write-Verbose "ConnectionBroker already deployed"
        }
        else {
            Write-Verbose "Adding New ConnectionBroker Deployment"
            Add-RDServer -Server $ConnectionBroker -Role 'RDS-CONNECTION-BROKER'
        }

        Write-Verbose "Checking WebAccessServer Deployment."
        if((Get-TargetResource @PSBoundParameters).WebAccessServer -ieq $WebAccessServer){
            Write-Verbose "WebAccessServer already deployed"
        }
        else {
            Write-Verbose "Adding New WebAccessServer Deployment"
            Add-RDServer -Server $WebAccessServer -ConnectionBroker $ConnectionBroker -Role 'RDS-WEB-ACCESS'
        }

        if ($GatewayServer) {
            Write-Verbose "Checking Gateway Deployment."
            if((Get-TargetResource @PSBoundParameters).GatewayServer -ieq $GatewayServer){
                Write-Verbose "Gateway already deployed"
            }
            else {
                Write-Verbose "Adding New Gateway Deployment"
                Add-RDServer -Server $GatewayServer -ConnectionBroker $ConnectionBroker -GatewayExternalFqdn $GatewayExternalFqdn -Role 'RDS-GATEWAY'
            }
        }
        
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
        [string] $SessionHost,
        [string] $ConnectionBroker = $localhost,
        [parameter(Mandatory)]
        [string] $WebAccessServer,
        [string] $GatewayExternalFqdn,
        [string] $GatewayServer
    )
    Write-Verbose "Checking RDSH role(s) is deployed on this node."
    $TestResult = $false

    $GetTargetResourceResults = Get-TargetResource @PSBoundParameters
    if ($GetTargetResourceResults.SessionHost -ieq $SessionHost ) {
        Write-Verbose "SessionHost Role is deployed on $SessionHost"
        $TestResult = $true
    }
    else {
        Write-Verbose "SessionHost Role is MISSING on $SessionHost"
        Return $false
    }

    if ($GetTargetResourceResults.ConnectionBroker -ieq $ConnectionBroker ) {
        Write-Verbose "ConnectionBroker Role is deployed on $ConnectionBroker"
        $TestResult = $true
    }
    else {
        Write-Verbose "ConnectionBroker Role is MISSING on $ConnectionBroker"
        Return $false
    }

    if ($GetTargetResourceResults.WebAccessServer -ieq $WebAccessServer ) {
        Write-Verbose "WebAccessServer Role is deployed on $WebAccessServer"
        $TestResult = $true
    }
    else {
        Write-Verbose "WebAccessServer Role is MISSING on $WebAccessServer"
        Return $false
    }

    if ($GatewayServer) {
        if ($GetTargetResourceResults.GatewayServer -ieq $GatewayServer ) {
            Write-Verbose "GatewayServer Role is deployed on $GatewayServer"
            $TestResult = $true
        }
        else {
            Write-Verbose "GatewayServer Role is MISSING on $GatewayServer"
            Return $false
        }
    }
    else {
        Write-Verbose "No GatewayServer specified in configuration"
    }

    Return $TestResult
}


Export-ModuleMember -Function *-TargetResource
