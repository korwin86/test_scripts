#скрипт настройки запуск под юзером

#путь до файлика ibases с базами
$pathTo1cBaseList = " "


################################################################################################################################
Write-Host "============Устанавливаем значок поиска вместо поля"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 1 
Write-Host "============Убираем кнопку просмотра задач"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0

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

################################################################################################################################
Write-Host "============Устанавливаем принтер по умолчанию"
Write-Host "============Настраиваем реестр"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "LegacyDefaultPrinterMode" -Value 1 -Force
Write-Host "============Ищем принтеры и мфу"
$wsnObj = New-Object -COM WScript.Network
$printers = Get-Printer
Write-Host "============Установленные принтеры:"
$i = 0
foreach ($printer in $printers) {
    Write-Host $i $printer.Name
    $i++
}
$pr = read-host "Введите номер принтера в диапазон от 0 до"($printers.count - 1)
while ($true) {
    if (($pr -ge 0) -and ($pr -lt $printers.count) -and ($pr.Length -eq 1 ) ) {
        $wsnObj.SetDefaultPrinter($printers[$pr].Name)
        Write-Host "============Принтер"$printers[$pr].Name"установлен по умолчанию"
        break;
    }
    else {        
        $pr = read-host "введен некорректный номер, для продолжения введите номер принтера в диапазон от 0 до"($printers.count - 1)
    }
}

Write-Host "============Рестарт explorer"
Stop-Process -Name Explorer

Write-Host "============Копируем список баз 1С"
Copy-Item "$pathTo1cBaseList\ibases.v8i" -Destination 'AppData\Roaming\1C\1CEStart\'