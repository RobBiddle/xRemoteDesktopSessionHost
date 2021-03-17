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
        [ValidateSet("RDGateway", "RDPublishing", "RDRedirector", "RDWebAccess")]        
        [string]
        $Role,
        [string] 
        $Thumbprint
    )
    Write-Verbose "Getting RD Certificate Configuration"
    $CertificateConfiguration = Get-RDCertificate -ConnectionBroker $ConnectionBroker -Role $Role -ErrorAction SilentlyContinue
    
    @{
        "Role"      = $CertificateConfiguration.Role
        "Level"     = $CertificateConfiguration.Level
        "ExpiresOn" = $CertificateConfiguration.ExpiresOn
        "IssuedTo"  = $CertificateConfiguration.IssuedTo
        "Thumbprint"  = $CertificateConfiguration.Thumbprint
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
        [ValidateSet("RDGateway", "RDPublishing", "RDRedirector", "RDWebAccess")]        
        [string]
        $Role,
        [string] 
        $Thumbprint
    )
    Write-Verbose "Checking for existence of specified Certificate."
    $Certificate = Get-ChildItem Cert:\LocalMachine -Recurse | Where-Object Thumbprint -IMatch $Thumbprint
    if (-NOT $Certificate) {
        Write-Error "No Certificate found with Thumbprint matching $Thumbprint"
    }
    else {
        Write-Verbose "Setting RD Certificate Configuration."
        # Set-RDCertificate expects to import a PFX file.
        # Existing certificate will be exported to PFX, secured to the account running this DSC configuration.
        $CertificatePfxFile = "$env:TEMP\$($Role)_Certificate.pfx"
        Export-PfxCertificate -Cert "$($Certificate.PSParentPath)\$Thumbprint" -FilePath $CertificatePfxFile -ProtectTo $env:USERNAME -Force
        Set-RDCertificate -Role $Role -ImportPath $CertificatePfxFile -ConnectionBroker $ConnectionBroker -Force -ErrorAction Continue
        if ($Role -imatch "RDGateway") {
            # RemoteDesktopServices module required for PowerShell Remote Desktop Services Provider
            Import-Module RemoteDesktopServices -Force -Verbose:$false
            if (-NOT ((get-item RDS:\GatewayServer\SSLCertificate\Thumbprint).CurrentValue -imatch $Thumbprint)) {
                Set-Item RDS:\GatewayServer\SSLCertificate\Thumbprint -Value $Thumbprint    
            }
            
        }
        # PFX file is deleted following import  
        Remove-Item $CertificatePfxFile -Force
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
        [ValidateSet("RDGateway", "RDPublishing", "RDRedirector", "RDWebAccess")]        
        [string]
        $Role,
        [string] 
        $Thumbprint
    )
    Write-Verbose "Checking RD Certificate Configuration."
    $PSBoundParameters.Remove("Verbose") | out-null
    $PSBoundParameters.Remove("Debug") | out-null
    $Check = $true
    $Get = Get-TargetResource @PSBoundParameters
    $PSBoundParameters.Remove("ConnectionBroker") | out-null
    $PSBoundParameters.keys | ForEach-Object {
        if ($PSBoundParameters[$_] -ine $Get[$_]) {
            $Check = $false
        } 
    }

    $Check
}

Export-ModuleMember -Function *-TargetResource
