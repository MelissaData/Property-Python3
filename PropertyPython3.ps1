<#
.SYNOPSIS
    Runs the Melissa Property Cloud API Python 3 sample.

.DESCRIPTION
    This script runs PropertyPython3.py with python3, passing along the license
    and (if supplied) the lookup fields.

    Overall flow:
      1. Resolve the license (parameter, prompt, or MD_LICENSE environment variable).
      2. Run PropertyPython3.py: with the lookup fields if any was supplied,
         otherwise with only the license (the Python program prompts for each field).

.PARAMETER fips
    County FIPS code to test.

.PARAMETER apn
    Assessor's Parcel Number (APN) to test.

.PARAMETER license
    License string. Resolved in this order:
      1. This parameter.
      2. An interactive prompt, if the parameter was not supplied.
      3. The MD_LICENSE environment variable, if the prompt was left blank.
    Note that the environment variable is the last resort, not the first: running
    without -license always prompts, even when MD_LICENSE is set.

.PARAMETER quiet
    Accepted for parity with other sample scripts; not currently used to suppress output.

.EXAMPLE
    .\PropertyPython3.ps1 -license "your-license"

.EXAMPLE
    .\PropertyPython3.ps1 -fips "06059" -apn "80505208" -license "your-license"
#>

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
# No lookup fields supplied -> run with only the license (the program prompts); otherwise pass the supplied ones through.
if ([string]::IsNullOrEmpty($fips) -and [string]::IsNullOrEmpty($apn)) {
  python3 PropertyPython3.py --license $license
}
else {
  # Only pass flags that have a value. Windows PowerShell drops empty-string arguments to
  # native programs, which would shift the next flag name into this flag's value.
  # Any field left out here is prompted for by the program.
  $runArgs = @('--license', $license)
  if (-not [string]::IsNullOrEmpty($fips)) { $runArgs += '--fips', $fips }
  if (-not [string]::IsNullOrEmpty($apn))  { $runArgs += '--apn', $apn }
  python3 PropertyPython3.py @runArgs
}
