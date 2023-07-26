# Name:    Property
# Purpose: Execute the PropertyCloudAPI program

######################### Parameters ##########################
param(
    $fips = '',  
    $apn = '',  
    $license = '', 
    [switch]$quiet = $false
    )

########################## Main ############################
Write-Host "`n======================== Melissa Property Cloud Api ===========================`n"

# Get license (either from parameters or user input)
if ([string]::IsNullOrEmpty($license) ) {
  $license = Read-Host "Please enter your license string"
}

# Check for License from Environment Variables 
if ([string]::IsNullOrEmpty($license) ) {
  $license = $env:MD_LICENSE
}

if ([string]::IsNullOrEmpty($license)) {
  Write-Host "`nLicense String is invalid!"
  Exit
}

# Run project
if ([string]::IsNullOrEmpty($fips) -and [string]::IsNullOrEmpty($apn)) {
  python3 PropertyPython3.py --license $license 
}
else {
  python3 PropertyPython3.py --license $license --fips $fips --apn $apn
}
