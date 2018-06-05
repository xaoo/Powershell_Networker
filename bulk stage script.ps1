$stage = @()
$stage = get-content C:\tmp\stage.txt
$i = 1
$c =$stage.Count

foreach($item in $stage){
    Write-host "$i. Staging $item, "($c-$i)" to stage."
    nsrstage.exe -v -b BCKNZMaanedTape -m -S $item
    $i++
}