#Requires -RunAsAdministrator

echo "PFX file path: $env:CERT_PATH_PFX"
$newCert = Import-PfxCertificate -FilePath "$env:CERT_PATH_PFX" -CertStoreLocation Cert:\LocalMachine\My
echo "Imported certificate to localmachine: $newCert.Thumbprint"

# Script for IIS
if (Get-Module -ListAvailable -Name Webadministration) 
{
    Import-Module Webadministration 
    echo "Updating certificate for IIS"

    $sites = Get-ChildItem -Path IIS:\Sites

    foreach ($site in $sites)
    {
        foreach ($binding in $site.Bindings.Collection)
        {
            if ($binding.protocol -eq 'https')
            {
                $search = "Cert:\LocalMachine\My\$($binding.certificateHash)"
                $certs = Get-ChildItem -path $search -Recurse
                $hostname = hostname
                
                if (($certs.count -gt 0) -and 
                    ($certs[0].Subject.StartsWith("CN=$env:CERT_DOMAIN")))
                {
                    echo "Updating $hostname, site: `"$($site.name)`", binding: `"$($binding.bindingInformation)`", current cert: `"$($certs[0].Subject)`", Expiry Date: `"$($certs[0].NotAfter)`""

                    $binding.AddSslCertificate($newCert.Thumbprint, "my")
                }
            }
        }
    }

} 
else
{
    Write-Host "IIS Module Webadministration does not exist, ignore"
}