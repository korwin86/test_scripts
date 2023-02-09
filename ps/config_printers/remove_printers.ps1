# Чистим принтеры!

# Убираем print to pdf
Disable-WindowsOptionalFeature -FeatureName "Printing-PrintToPDFServices-Features" -Online -NoRestart -Verbose
# Убираем Microsoft XPS Document Writer
Disable-WindowsOptionalFeature -FeatureName "Printing-XPSServices-Features" -Online -NoRestart -Verbose
# Убираем fax
Get-WindowsCapability -Online | Where-Object -Property Name -Like "*fax*" | Remove-WindowsCapability -Online -Verbose
# Удаляем принтеры, драйверы(из сервера печати, не из винды!) и порты
$printers = Get-Printer
$printers | Remove-Printer -Verbose
Remove-PrinterDriver -Name * -Verbose
Remove-PrinterPort -Name $printers.PortName -Verbose

# Вычещаем винду от драйверов выбранных производителей(только принтеры)
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

# Предлогаем рестарт(в чем смысл, не помню)
write-host "Для нормального завершения скрипта нужно перезагрузить комп."
write-host "Это можно сделать позже"
write-host "Для продолжения введиет Y чтобы перезагрузить компьютер и N чтобы продолжить без перезагрузки:"

$reboot=read-host

while ($true) {
    if ($reboot -eq "Y" -or $reboot -eq "y" -or $reboot -eq "Н" -or $reboot -eq "н") {
        Restart-Computer -Verbose
    }
    elseif ($reboot -eq "N" -or $reboot -eq "n" -or $reboot -eq "Т" -or $reboot -eq "т") { 
     break;
     read-host "Для выхода нажмите enter"
    }
    else {
        write-host "Для продолжения введиет Y чтобы перезагрузить компьютер и N чтобы продолжить без перезагрузки:"
        $reboot=read-host
    }
}
