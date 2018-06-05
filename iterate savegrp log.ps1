#----------------------------------------------------------------------
# Name:           Report on Failed/Succedded jobs based on nsrlog 
#                 Notification, in txt format
# Version:        1.0.0.0
# Author:         George Dicu
# Start date:     27.12.2015
# Release date:   27.12.2015
# Description:    
#
# Author:         
# Department:     Cloud, Backup  
#--------------------------------------------------------------------
$savegrp = Get-Content "J:\savegrp.dec.2015.log"

$succeded = ($savegrp -cmatch "Succeeded:") -replace "\s+",";" -replace ",","" -replace ":",""

$failed = ($savegrp -cmatch " Failed: ") -replace "\s+",";" -replace ",","" -replace ":",""

$container = @()
$container += "Date;Time;Client;Status"
$date =  Get-Date -format dd.MMMM.yyyy

for($i=0;$i -le ($succeded.count-1);$i++) {

    $s1 = ($succeded[$i]).split(";")

    if ($s1.count -eq 6){
   
        $container += "$($s1[1]) $($s1[0]);$($s1[2]);$($s1[5]);$($s1[4])"
    }
    else{
        $count = ($s1.count)

        for($a = $count-1;$a -ge 5){
            $container += "$($s1[1]) $($s1[0]);$($s1[2]);$($s1[$a]);$($s1[4])"
            $a--
        }
    }
}

for($i=0;$i -le ($failed.count-1);$i++) {

   $f1 = ($failed[$i]).split(";")

   if ($f1.count -eq 6){
   
        $container += "$($f1[1]) $($f1[0]);$($f1[2]);$($f1[5]);$($f1[4])"
    }
    else{
        $count = ($f1.count)

        for($a = $count-1;$a -ge 5){
            $container += "$($f1[1]) $($f1[0]);$($f1[2]);$($f1[$a]);$($f1[4])"
            $a--
        }
    }
}

 $container | ForEach-Object {
    $PSItem.GetEnumerator()
    } | Export-Csv "J:\BDK $date.csv"