$exp = @()
$exp = get-content C:\tmp\notrecyclable.txt
#ssid/cloneid
$i = 1
$c =$exp.Count

foreach($item in $exp){
    Write-host "$i. Flag $item, "($c-$i)" to norecyclable."
    nsrmm -s nwbck01 -o notrecyclable -S $item -y
    $i++
}

