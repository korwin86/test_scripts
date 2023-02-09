# настройка принтеров в винде

Write-Host "================================================"
Write-Host "Удаляем всё"
# убираем принтер onenote отдельно, если он есть
Start-Process powershell -ArgumentList "-Command & {Get-AppxPackage *OneNote* | remove-appxPackage}" -Wait
Start-Process powershell -ArgumentList "-File .\remove_printers.ps1" -Verb RunAs -Wait
Write-Host "================================================"
Write-Host "Устанавливаем всё"
Start-Process powershell -ArgumentList "-File .\add_printers.ps1" -Verb RunAs -Wait
Write-Host "================================================"
Write-Host "Выбираем по умолчанию"
Start-Process powershell -ArgumentList "-File .\set_default_printer.ps1" -Wait
Write-Host "================================================"
Write-Host "Готово"
read-host "Для выхода нажмите enter"