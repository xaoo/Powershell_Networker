#VBA pools that need 13 mothts ret and 5 years
$vmpools = @()
$vmpools = "VMIP","VMNZ"

#1st save all ssids from a day ago, since this script will run on 3rd of each month
foreach ($item in $vmpools) {
    $ssids = mminfo -avot -xc";" -q "type=Data Domain,copies=1,pool=$item,savetime>=2 day ago" -r "savetime,ssid,cloneid,clretent,pool,volume,type"


    $toclone = @()
    foreach($ssid in $ssids[1..($ssids.count-1)]){
        $toclone += $ssid.split(";")[1]+"/"+$ssid.split(";")[2]
    }

    Set-Content C:\tmp\$item -Value $toclone

    #get the current month to see if it`s month abckup of yearly
    [int]$month = get-date -format "MM"
    if($month -eq 12){
        if($item -eq "VMNZ"){
            $pool = "BCKNZYEARTAPE"
        }
        else{
            $pool = "BCKIPYearlyTape"
        }

        #nsrclone -b $pool -y "5 years" -w "5 years" -o -I -f C:\tmp\$item -F -S
    }
    else {
        if($item -eq "VMNZ"){
            $pool = "BCKNZMaanedTape"
        }
        else{
            $pool = "BCKIPMaanedTape"
        }

        #nsrclone -b $pool -y "13 month" -w "13 month" -o -I -f C:\tmp\$item -F -S
    }

}

2233477807/1428171439
1772633327/1420311791
