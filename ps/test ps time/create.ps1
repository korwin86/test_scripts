for ($i = 1; $i -le 60; $i++)
{
    New-Item -Path 'C:\test\t' -Name $i -ItemType File -force
}
for ($i = 1; $i -le 30; $i++)
{
    $item = Get-ChildItem 'C:\test\t\'$i
	$item.CreationTime = ("08.$i.2022 12:00:00")
	$item.LastWriteTime = ("08.$i.2022 12:00:00")
	$item.LastAccessTime = ("08.$i.2022 12:00:00")
}
for (($i = 31), ($j=1); $i -le 60; ($i++), ($j++))
{
    $item = Get-ChildItem 'C:\test\t\'$i
	$item.CreationTime = ("07.$j.2022 12:00:00")
	$item.LastWriteTime = ("07.$j.2022 12:00:00")
	$item.LastAccessTime = ("07.$j.2022 12:00:00")
}