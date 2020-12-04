Import-Module $env:SyncroModule

<#

.SYNOPSIS
  Download the latest Perch Security log shipper agent, and get the cloud install
  token from the customer profile, install silently.

.DESCRIPTION
  Installs the Perch Security Log Shipper agent for threat hunting services via
  Perch Security's SOC.

.INSTRUCTIONS
  Create a custom field in your customer object (probably called "PerchToken" or
  something like that), then add the script variable here called $perchy (set it
  to a platform variable and find the value from your customer object).  If you
  want to set a default token to use should a customer-specific token not be available,
  edit that below.  This is optional, and nothing below that would need to be edited.

#>

$default_token = ""

$download_location = "https://cdn.perchsecurity.com/downloads/perch-log-shipper-latest.exe"

$use_token = $perchy

if ($use_token -eq "") {
    $use_token = $default_token
}

function download_file($file_url, $save_to_path) {
    (New-Object System.Net.WebClient).DownloadFile($file_url,$save_to_path)
    if (Test-Path $save_to_path) {
        return $true
    }
    return $false
}

function is_installed() {
    if (Get-Service "perch-auditbeat" -ErrorAction SilentlyContinue) {
        return $true
    }
    return $false
}

try {
    if (is_installed) {
        Write-Host "Perch log shipper is already installed."
    }else {
        $res = download_file $download_location "C:\perch-log-shipper-latest.exe"
        if ($res) {
            Start-Process "C:\perch-log-shipper-latest.exe" -ArgumentList "/qn","OUTPUT=`"TOKEN`"","VALUE=`"$use_token`"" -Wait
            if (is_installed) {
                Write-Host "Installation successful"
            }else {
                Write-Host "Installation failed"
            }
        }else {
            Write-Host "Download failed."
        }
    }
} catch {
    $error = $_.Exception.Message
    Write-Output $error
    exit -1
}