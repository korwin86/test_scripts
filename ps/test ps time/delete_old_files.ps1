#Дата с которой сравнивать. В этом случае -15 дней от текущей даты
$date = (Get-Date).AddDays(-16)
#Или дата кастомная. Пустые значения будут взяты из текущего времени и даты
#$date = Get-Date -Year 2022 -Month 08 -Day 14 -Hour 12 -Minute 00
#Путь до директории откуда удалять файлы
#$path = "C:\test\t"
#Удаление всех файлов и папок (в т.ч. внутри папок) старше чем значение в $date
#Get-ChildItem -Recurse -Path $path | Where-Object -Property CreationTime -gT $date | Remove-Item
Get-ChildItem C:\test\t | Where-Object -Property CreationTime -le $date | Remove-Item