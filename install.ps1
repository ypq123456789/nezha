#Get server and key
param($server, $key, $tls)
# Download fixed version from gitee
if($PSVersionTable.PSVersion.Major -lt 5){
    Write-Host "Require PS >= 5,your PSVersion:"$PSVersionTable.PSVersion.Major -BackgroundColor DarkGreen -ForegroundColor White
    Write-Host "Refer to the community article and install manually! https://nyko.me/2020/12/13/nezha-windows-client.html" -BackgroundColor DarkRed -ForegroundColor Green
    exit
}
#  x86 or x64 or arm64
if ([System.Environment]::Is64BitOperatingSystem) {
    if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
        $file = "nezha-agent_windows_arm64.zip"
    } else {
        $file = "nezha-agent_windows_amd64.zip"
    }
}
else {
    $file = "nezha-agent_windows_386.zip"
}

#重复运行自动更新
if (Test-Path "C:\nezha\nezha-agent.exe") {
    Write-Host "Nezha monitoring already exists, delete and reinstall" -BackgroundColor DarkGreen -ForegroundColor White
    C:\nezha\nezha-agent.exe service uninstall
    Remove-Item "C:\nezha" -Recurse
}
#TLS/SSL
Write-Host "Using fixed version v0.20.5" -BackgroundColor DarkGreen -ForegroundColor White
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$download = "https://gitee.com/pei_qiang_yang/agent/raw/main/agent-v0.20.5.zip"
echo $download
Invoke-WebRequest $download -OutFile "C:\nezha.zip"
#解压
Expand-Archive "C:\nezha.zip" -DestinationPath "C:\temp" -Force
if (!(Test-Path "C:\nezha")) { New-Item -Path "C:\nezha" -type directory }
#整理文件
Move-Item -Path "C:\temp\nezha-agent.exe" -Destination "C:\nezha\nezha-agent.exe"
#清理垃圾
Remove-Item "C:\nezha.zip"
Remove-Item "C:\temp" -Recurse
#安装部分
C:\nezha\nezha-agent.exe service install -s $server -p $key $tls
#enjoy
Write-Host "Enjoy It!" -BackgroundColor DarkGreen -ForegroundColor Red
