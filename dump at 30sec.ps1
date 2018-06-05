
for ($i=1;$i -le 10;$i++) {
    Write-Output "Dump $i"
    C:\tmp\processdump\procdump.exe -ma 5924
    Start-Sleep 30
}