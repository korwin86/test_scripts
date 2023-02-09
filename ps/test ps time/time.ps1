(Get-Item "C:\test\in\1").LastWriteTime=("08.01.2022 12:00:00")
(Get-Item "C:\test\in\2").LastWriteTime=("07.01.2022 12:00:00")
(Get-Item "C:\test\in\3").LastWriteTime=("06.01.2022 12:00:00")

Get-ChildItem -force C:\test\in\1 * | ForEach-Object{$_.CreationTime = ("08.01.2022 12:00:00")}
Get-ChildItem -force C:\test\in\1 * | ForEach-Object{$_.LastWriteTime = ("08.01.2022 12:00:00")}
Get-ChildItem -force C:\test\in\1 * | ForEach-Object{$_.LastAccessTime = ("08.01.2022 12:00:00")}

Get-ChildItem -force C:\test\in\2 * | ForEach-Object{$_.CreationTime = ("07.01.2022 12:00:00")}
Get-ChildItem -force C:\test\in\2 * | ForEach-Object{$_.LastWriteTime = ("07.01.2022 12:00:00")}
Get-ChildItem -force C:\test\in\2 * | ForEach-Object{$_.LastAccessTime = ("07.01.2022 12:00:00")}

Get-ChildItem -force C:\test\in\3 * | ForEach-Object{$_.CreationTime = ("06.01.2022 12:00:00")}
Get-ChildItem -force C:\test\in\3 * | ForEach-Object{$_.LastWriteTime = ("06.01.2022 12:00:00")}
Get-ChildItem -force C:\test\in\3 * | ForEach-Object{$_.LastAccessTime = ("06.01.2022 12:00:00")}