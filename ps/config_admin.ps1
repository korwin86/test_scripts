#скрипт настройки запуск под админом

################################################################################################################################
Write-Host "============Запускаем костыль для исправления кодировки"
powercfg /L

Write-Host "============Меням кодировку на cp866"
[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')


################################################################################################################################
Write-Host "============Получаем групповые политики"
gpupdate.exe /force

Write-Host "============Добавляем\обновляем dns запись"
Register-DnsClient

################################################################################################################################
# мфу
Write-Host "============Меням кодировку на windows-1251"
[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('windows-1251')

Write-Host "============Убираем print to pdf"
Disable-WindowsOptionalFeature -FeatureName "Printing-PrintToPDFServices-Features" -Online 
Write-Host "============Убираем Microsoft XPS Document Writer"
Disable-WindowsOptionalFeature -FeatureName "Printing-XPSServices-Features" -Online
Write-Host "============Убираем fax"
Get-WindowsCapability -Online | Where-Object -Property Name -Like "*fax*" | Remove-WindowsCapability -Online


Write-Host "============Удаляем принтеры, драйверы(из сервера печати, не из винды!) и порты"
$printers = Get-Printer
$printers | Remove-Printer
Remove-PrinterDriver -Name *
Remove-PrinterPort -Name $printers.PortName


Write-Host "============Вычещаем винду от драйверов выбранных производителей(только принтеры)"
$manufacturer = @("*Samsung*", "*KYOCERA*")
foreach ($name in $manufacturer) {                                                               # Если это убрать, можно удалить все драйвера принтеров
    $PrintDrivers = @(Get-WindowsDriver -Online | Where-Object { $_.ClassName -Like "Printer" } | Where-Object { $_.ProviderName -like $name })

    While ($PrintDrivers -ne "") {
        foreach ($printer in $PrintDrivers) {
            Write-Host "Удаляем $($printer.OriginalFileName)" 
            pnputil.exe /delete-driver $printer.Driver #/force(удалить в любом случае)
            Write-Host "Удалили $($printer.OriginalFileName)" 
        }                                                                                             # Если это убрать, можно удалить все драйвера принтеров
        $PrintDrivers = @(Get-WindowsDriver -Online | Where-Object { $_.ClassName -Like "Printer" } | Where-Object { $_.ProviderName -like $name })
    }
}

Write-Host "============Устанавливаем драйверы"

$drivers = @("ПУТЬ ДО ДРАЙВЕРА\samsung\ssn2m.inf"; "ПУТЬ ДО ДРАЙВЕРА\kyocera\64bit\OEMSETUP.INF")
foreach ($driver in $drivers) {
    pnputil.exe /add-driver $driver
}

###
# тут нужен список мфу с ip
# вида
# название порта, Ip, название мфу в винде, название драйвера из файла драйвера
# я сделал просто файлик и парсю его как csv
# начинается обязательно с этой строки потом для примера строка как должно быть
# portname;ip;desription;drivername
# 3145;192.168.1.1;Бухгалтерия;Kyocera ECOSYS M3145dn KX

$all_printers = Import-Csv ПУТЬ ДО СПИКА МФУ\list_printers -Delimiter ";"
foreach($printer in $all_printers){
    Add-PrinterDriver -Name $printer.drivername
    Add-PrinterPort -Name $printer.portname -PrinterHostAddress $printer.ip
    Add-Printer -Name $printer.desription -DriverName $printer.drivername -PortName $printer.portname
}


################################################################################################################################
# дефолтные проги и мусор

Write-Host "============Удаляем мусорные приложения"

$GarbageStagedApps = @(
    "Microsoft.BingWeather"
    "Microsoft.GetHelp"
    "Microsoft.Getstarted"
    "Microsoft.Microsoft3DViewer"
    "Microsoft.MicrosoftOfficeHub"
    "Microsoft.MicrosoftSolitaireCollection"
    "Microsoft.MicrosoftStickyNotes"
    "Microsoft.MixedReality.Portal"
    "Microsoft.Office.OneNote"
    "Microsoft.People"
    "Microsoft.ScreenSketch"
    "Microsoft.SkypeApp"
    "Microsoft.Wallet"
    "Microsoft.WindowsAlarms"
    "Microsoft.WindowsCamera"
    "microsoft.windowscommunicationsapps"
    "Microsoft.WindowsFeedbackHub"
    "Microsoft.WindowsMaps"
    "Microsoft.WindowsSoundRecorder"
    "Microsoft.Xbox.TCUI"
    "Microsoft.XboxApp"
    "Microsoft.XboxGameOverlay"
    "Microsoft.XboxGamingOverlay"
    "Microsoft.XboxIdentityProvider"
    "Microsoft.XboxSpeechToTextOverlay"
    "Microsoft.YourPhone"
    "Microsoft.ZuneMusic"
    "Microsoft.ZuneVideo"
)

foreach ($App in $GarbageStagedApps) {
    Get-AppxPackage -Name $App -AllUsers | Remove-AppxPackage 
    Get-AppXProvisionedPackage -Online | Where-Object DisplayName -eq $App | Remove-AppxProvisionedPackage -Online
    }

Write-Host "============Удаляем onedrive"
Stop-Process -Name OneDrive -Force -ErrorAction 0
"$env:SystemRoot\System32\OneDriveSetup.exe","$env:SystemRoot\SysWOW64\OneDriveSetup.exe" | Foreach {
	if(Test-Path $_) {
		Start-Process $_ -ArgumentList "/uninstall" -Wait
	}
}
$dir = "$env:USERPROFILE\OneDrive","C:\OneDriveTemp\","$env:LOCALAPPDATA\Microsoft\OneDrive","$env:ProgramData\Microsoft OneDrive" 
$dir | Foreach {
	Remove-Item -LiteralPath $_ -Force -Recurse
}
REG DELETE "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 
REG DELETE "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 
Reg.exe add "HKLM\SOFTWARE\Policies\Microsoft\Windows\OneDrive" /v "DisableFileSyncNGSC" /t REG_DWORD /d "1" /f

Write-Host "============Убираем иконку провести собрание"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "HideSCAMeetNow" -Value 1

Write-Host "============Устанавливаем значок поиска вместо поля"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1 

Write-Host "============Убираем кнопку просмотра задач"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0

Write-Host "============Закидываем ярлык мой компьютер на рабочий стол"
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel" -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0

Write-Host "============Рестарт explorer"
Stop-Process -Name Explorer

Write-Host "============Удаляем RSAT, если они есть"
# В обычном порядке не удаляет, тупо переместил вниз ActiveDirectory\GroupPolicy\ServerManager
$RSAT = @(
    "Rsat.BitLocker.Recovery.Tools~~~~0.0.1.0"
    "Rsat.CertificateServices.Tools~~~~0.0.1.0"
    "Rsat.DHCP.Tools~~~~0.0.1.0"
    "Rsat.Dns.Tools~~~~0.0.1.0"
    "Rsat.FailoverCluster.Management.Tools~~~~0.0.1.0"
    "Rsat.FileServices.Tools~~~~0.0.1.0"
    "Rsat.IPAM.Client.Tools~~~~0.0.1.0"
    "Rsat.LLDP.Tools~~~~0.0.1.0"
    "Rsat.NetworkController.Tools~~~~0.0.1.0"
    "Rsat.NetworkLoadBalancing.Tools~~~~0.0.1.0"
    "Rsat.RemoteAccess.Management.Tools~~~~0.0.1.0"
    "Rsat.RemoteDesktop.Services.Tools~~~~0.0.1.0"
    "Rsat.Shielded.VM.Tools~~~~0.0.1.0"
    "Rsat.StorageMigrationService.Management.Tools~~~~0.0.1.0"
    "Rsat.StorageReplica.Tools~~~~0.0.1.0"
    "Rsat.SystemInsights.Management.Tools~~~~0.0.1.0"
    "Rsat.VolumeActivation.Tools~~~~0.0.1.0"
    "Rsat.WSUS.Tools~~~~0.0.1.0"
    "Rsat.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0"
    "Rsat.GroupPolicy.Management.Tools~~~~0.0.1.0"
    "Rsat.ServerManager.Tools~~~~0.0.1.0"
)

foreach ($toolname in $RSAT) {
    Remove-WindowsCapability -Online -Name $toolname
    }

Write-Host "============Убираем иконки пуск"
#этот кусок скопипастил
$START_MENU_LAYOUT = @"
<LayoutModificationTemplate xmlns:defaultlayout="http://schemas.microsoft.com/Start/2014/FullDefaultLayout" xmlns:start="http://schemas.microsoft.com/Start/2014/StartLayout" Version="1" xmlns:taskbar="http://schemas.microsoft.com/Start/2014/TaskbarLayout" xmlns="http://schemas.microsoft.com/Start/2014/LayoutModification">
    <LayoutOptions StartTileGroupCellWidth="6" />
    <DefaultLayoutOverride>
        <StartLayoutCollection>
            <defaultlayout:StartLayout GroupCellWidth="6" />
        </StartLayoutCollection>
    </DefaultLayoutOverride>
</LayoutModificationTemplate>
"@
$layoutFile="C:\Windows\StartMenuLayout.xml"
If(Test-Path $layoutFile)
{
    Remove-Item $layoutFile
}
$START_MENU_LAYOUT | Out-File $layoutFile -Encoding ASCII
$regAliases = @("HKLM", "HKCU")
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    IF(!(Test-Path -Path $keyPath)) { 
        New-Item -Path $basePath -Name "Explorer"
    }
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 1
    Set-ItemProperty -Path $keyPath -Name "StartLayoutFile" -Value $layoutFile
}
Stop-Process -name explorer
Start-Sleep -s 5
$wshell = New-Object -ComObject wscript.shell; $wshell.SendKeys('^{ESCAPE}')
Start-Sleep -s 5
foreach ($regAlias in $regAliases){
    $basePath = $regAlias + ":\SOFTWARE\Policies\Microsoft\Windows"
    $keyPath = $basePath + "\Explorer" 
    Set-ItemProperty -Path $keyPath -Name "LockedStartLayout" -Value 0
}
Stop-Process -name explorer
Import-StartLayout -LayoutPath $layoutFile -MountPath $env:SystemDrive\
Remove-Item $layoutFile


################################################################################################################################
Write-Host "============Устанавливаем нужные проги по умолчанию"
# winget работает только если пользователь хоть раз авторизовался
$DefaultProgs = @(
    "Skillbrains.Lightshot"
    "Adobe.Acrobat.Reader.32-bit"
    "7zip.7zip"
    "Notepad++.Notepad++"
    "geeksoftwareGmbH.PDF24Creator"
    "CodecGuide.K-LiteCodecPack.Standard"
)
foreach ($DefaultProg in $DefaultProgs){
   winget install -e --id $DefaultProg --accept-package-agreements --accept-source-agreements
}

################################################################################################################################
Write-Host "============Обновляем систему"
Install-PackageProvider -Name NuGet -Force
Install-Module -Name PSWindowsUpdate -Force
Get-WindowsUpdate -AcceptAll -Install -IgnoreReboot 

################################################################################################################################
Write-Host "============Меням кодировку на cp866"
[Console]::outputEncoding = [System.Text.Encoding]::GetEncoding('cp866')
Write-Host "============Настраиваем схемы питания"
$HightPerfStr = powercfg /L | Where-Object {$_ -like "*Высокая производительность*"} | Out-String
$HightPerfStr -match '.{8}-(.{4}-){3}.{12}'
$HightPerfId = $Matches[0]
powercfg /S $HightPerfId
Write-Host "============Отключает режим гибернации"
POWERCFG /HIBERNATE OFF

################################################################################################################################
Write-Host "============Убираем яндекс музыка"
Get-AppxPackage *Yandex.Music* -AllUsers| Remove-AppPackage -AllUsers

################################################################################################################################
Write-Host "============Включаем smb протокол"
Enable-WindowsOptionalFeature -Online -FeatureName "SMB1Protocol" -All -NoRestart


################################################################################################################################
Write-Host "============Установка 1с"
$Ver1C = "windows_8_3_22_1709"
$PathTo1C = "ПУТЬ ДО 1С\$Ver1C"
& "$PathTo1C\1CEnterprise 8.msi" /qn TRANSFORMS='adminstallrelogon.mst;1049.mst' DESIGNERALLCLIENTS=1 THICKCLIENT=1 THINCLIENTFILE=1 THINCLIENT=1 WEBSERVEREXT=0 SERVER=0 CONFREPOSSERVER=0 CONVERTER77=0 SERVERCLIENT=0 DefLangAutoSelection=RU
# тут копирую файл nethasp.ini где у меня прописаны Ip компов с ключами 1с, если оно надо
Copy-Item "путь до файла\nethasp.ini" -Destination 'C:\Program Files (x86)\1cv8\conf' -Force


################################################################################################################################
Write-Host "============Установка офиса"
$Office = read-host "Какой офис устанавливаем?
1. 2010
2. 2013
3. 2016
4. отмена
"
while ($true) {
if (($Office -ge 1) -and ($Office -le 3)) {
    switch ($Office)
        {
            1 {& путь до папки с офисами\office\2010\Office_HB_2010_Russian_x32.exe; Break}
            2 {& путь до папки с офисами\2013\Setup.x86.ru-RU_HomeBusinessRetail_QW8P7-N248Q-44FCV-Q7D8G-BPW9D_TX_PR_.exe; Break}
            3 {& путь до папки с офисами\2016\Setup.exe; Break}
        }
    break;
}
elseif ($Office -eq 4) {
    break;
}
else {        
$Office = read-host "Какой офис устанавливаем?
1. 2010
2. 2013
3. 2016
4. отмена
" 
}
}