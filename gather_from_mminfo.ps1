cd E:
cd E:\PRA\CLone\

$a=@()
$a=('mbauditclone',
'mbcloneindex',
'mbclonepraasad1',
'mbclonepraasad2',
'mbclonepraasad3',
'mbclonepraasad4',
'mbcloneprabw1',
'mbcloneprabw2',
'mbcloneprabw3',
'mbcloneprabw4',
'mbclonepraecc1',
'mbclonepraecc2',
'mbclonepraecc3',
'mbclonepraecc4',
'mbcloneprasavsclc1',
'mbcloneprasavsclc3',
'mbcloneprasavsclc2',
'mbcloneprasavsclc4',
'mbcloneprasm1',
'mbcloneprasm2',
'mbcloneprasm3',
'mbcloneprasm4',
'mbcloneyearPR1')

foreach ($i in $a) {
	write-output $i
	(mminfo -a -xc"#" -q "pool=$i"  -r "volume,client,savetime,totalsize,type,name,clretent") > E:\PRA\CLone\$i.txt
}