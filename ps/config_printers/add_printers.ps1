# указываем файлы с драйверами принтеров\мфу *.inf
$drivers = @("\\папка_с_драйвеарами\драйвер\файл.INF"; "\\папка_с_драйвеарами\еще_какой-то_драйвер\файл.INF")

# устанавливаем в цикле выбранные драйверы
foreach ($driver in $drivers) {
    pnputil.exe /add-driver $driver
}

# получаем любым способом массив с принтерами\мфу для цикла
# для установки нужны имя драйвера(берется из *.inf файла) - drivername
# имя порта(как он в винде будет называться) - portname
# ip принтера - ip
# название принтера(как он в винде будет называться) - desription
# тут использую просто csv файл с разделителем `;`
$all_printers = Import-Csv .\list_printers -Delimiter ";"


# в цикле устанавливаем принтеры\мфу из массива
foreach($printer in $all_printers){
    Add-PrinterDriver -Name $printer.drivername -Verbose
    Add-PrinterPort -Name $printer.portname -PrinterHostAddress $printer.ip -Verbose
    Add-Printer -Name $printer.desription -DriverName $printer.drivername -PortName $printer.portname -Verbose
}

read-host "Для выхода нажмите enter"