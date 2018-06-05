#----------------------------------------------------------------------
# Name:           Report on Failed/Succedded jobs based on nsrlog 
#                 Notification, in csv format
# Version:        1.0.0.0
# Author:         George Dicu
# Start date:     27.12.2015
# Release date:   27.12.2015
# Description:    
#
# Author:         
# Department:     Cloud, Backup  
#--------------------------------------------------------------------
#add the log file.
$savegrp = Get-Content "J:\savegrp.dec.2015.log"
#filtering into a var just Succeeded/Failed data then replace  space with ';' and remove ','
$succeded = ($savegrp -cmatch "Succeeded:") -replace "\s+",";" -replace ",",""
$failed = ($savegrp -cmatch " Failed: ") -replace "\s+",";" -replace ",",""

#creating container where all data will be added
$container = @()
#just a date to save the csv file if this script will be scheduled 
$date =  Get-Date -format dd.MMMM.yyyy

#take each line of data with 'Succeeded' match and iterate it
for($i=0;$i -le ($succeded.count-1);$i++) {
    
    #split each line by ';' to see how many items are per one line
    $s1 = ($succeded[$i]).split(";")

    #if in one 'Succeeded' line are just 6 element then is just one server which is ok
    if ($s1.count -eq 6){
        
        $PropertyHash = @{}
        $PropertyHash =  @{
            "Date" = $s1[1] + " " + $s1[0]
            "Time" = $s1[2]
            "Client" = $s1[5]
            "Status" = $s1[4].Substring(0,9)
        }
        $container += New-Object -TypeName PSObject -Property $PropertyHash
    }
    #if in one 'Succeeded' line are more servers, then stick all sererers to the same info in the line
    else{
        $count = ($s1.count)

        for($a = $count-1;$a -ge 5){
            
            $PropertyHash = @{}
            $PropertyHash +=  @{
                "Date" = $s1[1] + " " + $s1[0]
                "Time" = $s1[2]
                "Client" = $s1[$a]
                "Status" = $s1[4].Substring(0,9)
            }
            $container += New-Object -TypeName PSObject -Property $PropertyHash
            $a--
        }
    }
}
for($i=0;$i -le ($failed.count-1);$i++) {

    $f1 = ($failed[$i]).split(";")

    if ($f1.count -eq 6){
        
        $PropertyHash = @{}
        $PropertyHash =  @{
            "Date" = $f1[1] + " " + $f1[0]
            "Time" = $f1[2]
            "Client" = $f1[5]
            "Status" = $f1[4].Substring(0,6)
        }
        $container += New-Object -TypeName PSObject -Property $PropertyHash
    }
   else{
        $count = ($f1.count)

        for($a = $count-1;$a -ge 5){
            
            $PropertyHash = @{}
            $PropertyHash +=  @{
                "Date" = $f1[1] + " " + $f1[0]
                "Time" = $f1[2]
                "Client" = $f1[$a]
                "Status" = $f1[4].Substring(0,6)
            }
            $container += New-Object -TypeName PSObject -Property $PropertyHash
            $a--
        }
    }
}

$container | Export-Csv "J:\BDK_($date -format dd.MM.yyy).csv" -NoTypeInformation