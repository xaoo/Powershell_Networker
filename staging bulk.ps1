$v = @()
$v = get-content C:\temp\staged.txt
$i = 0
$c = $v.count

foreach($item in $v){
        write-output "Staging ssid $i, $item"
        nsrstage -b Quarterly -m -S $item
        write-output "$i finished stages, "($c-$i)" left to stage."
        $i++
}