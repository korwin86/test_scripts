# для удобства можно сразу настроить дефолтный принтер для печати

# говорим винде что теперь мы сами выбираем куда печатать по умолчанию
Write-Host "==========================================================="
Write-Host "Установка принтера по умолчанию"
Write-Host "==========================================================="
Write-Host "настраиваем реестр:"
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Windows" -Name "LegacyDefaultPrinterMode" -Value 1 -Force -Verbose

# эта штука умеет ставить дефолтный принтер
$wsnObj = New-Object -COM WScript.Network

# печатаем все установленные принтеры
$printers = Get-Printer
Write-Host "==========================================================="
Write-Host "установленные принтеры:"
$test = 0
foreach ($printer in $printers) {
    Write-Host $test $printer.Name
    $test++
}

# получаем номер принтера и ставим его дефолтным
$pr = read-host "введите номер принтера в диапазон от 0 до"($printers.count - 1)
while ($true) {
    if (($pr -ge 0) -and ($pr -lt $printers.count) -and ($pr.Length -eq 1 ) ) {
        $wsnObj.SetDefaultPrinter($printers[$pr].Name)
        Write-Host "принтер"$printers[$pr].Name"установлен по умолчанию"
        break;
    }
    else {        
        $pr = read-host "введен некорректный номер, для продолжения введите номер принтера в диапазон от 0 до"($printers.count - 1)
    }
}

read-host "Для выхода нажмите enter"