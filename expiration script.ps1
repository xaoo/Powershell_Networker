$exp = @()
$exp = get-content C:\tmp\exp.txt
$i = 1
$c =$exp.Count

foreach($item in $exp){
    Write-host "$i. Expiring $item, "($c-$i)" to expire."
    nsrmm -dy -S $item
    $i++
}

