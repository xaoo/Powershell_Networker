#----------------------------------------------------------------------
# Name:           Report tape status on all jukeboxes(libraries)
#                 also VTLs, DD VTLs
# Version:        1.0.0.0
# Author:         George Dicu
# Start date:     28.12.2015
# Release date:   xx.12.2015
# Description:    
#
# Author:         
# Department:     Cloud, Backup, RO 
#--------------------------------------------------------------------

$libraries = @()
$container = @()
$hn = hostname
[string]$attch = ""

#//////////////////////////////////////////
#CONSTANTS
#//////////////////////////////////////////
#If you want to include the DataDomain, 
#change $DD = $false to $DD = $true
#by default it`s exluded
$DD = $false
#If you want to do a fastinventory on jukeboxes 
#change $fastinventory = $false to $fastinventory = $true
#by default it`s exluded
$fastinventory = $false
#Mail variables, you can change the content of them as you need
$to = "DK_Shared_NetWorker@atos.net"
$subject = $hn.ToUpper()+" Tape Libraries Status"
$body = "Hello,||This is an automated tape status report on "+$hn.ToUpper()+" Libraries||RO Backup Team"
#save script path location
$path = "D:\nsr\scripts"


#//////////////////////////////////////////
#SCRIPT BLOCK
#//////////////////////////////////////////
#trim Library name from double quotes char
function trim {
    $args[0] = $args[0] -replace "`"",""
    return $args[0]
}

#nsramdin command
$nsrjukeboxes = 
@"
. type: NSR jukebox
show name;comment;enabled
print
"@
#save nsradmin output after execution
$jukeboxes = $nsrjukeboxes | nsradmin.exe -i -

$jbsname = $jukeboxes -match "name:"
$jbscomment = $jukeboxes -match "comment:"
$jbsenabled = $jukeboxes -match "enabled:"

$i = 0
foreach($jbname in $jbsname){
    $PropertyHash = @{}
    $PropertyHash =  @{
        "Name" = trim($jbname.split(":",2)[-1].trim() -replace ";","")
        "Comment" = $jbscomment[$i].split(":",2)[-1].trim() -replace ";",""
        "Enabled" = $jbsenabled[$i].split(":",2)[-1].trim() -replace ";",""
    }
    $container += New-Object -TypeName PSObject -Property $PropertyHash
    $i++
}

$i = 0
$jbblat = @()
foreach ($jb in $container){
    if(!$DD){
        if($jb.Comment -eq "DataDomain") {
            continue
        }
    }
    if($jb.Enabled -eq "No") {
        continue
    }
    #this v is only for blat to send all files at once
    $jbblat += $jb.Name
    
    #create new variable name dinamicly for all Libraries.
    #we create it with JB+$i because we can have Libraries Names who can be incompatible with variable names
    #New-Variable -Name ($jb.Name)
    $jbtmp = $jb.Name
    Set-Variable -name $jb.Name -Value (mminfo -aot -xc~ -q "family=tape,location=$jbtmp" -r "pool,barcode,volretent,location,%used")
    
    $tmp = @()
    $tmp2 = @()
    #saveing current jukebox 
    $tmp2 = nsrjb -C -j $jbtmp
    $tmp2 = $tmp2[3..($tmp2.count-1)]
    $jbcontainer = @()
    
    #Fast Inventory Robot
    if($fastinventory){
        nsrjb -j $jbtmp -IIq
    }
    
    
    foreach($item in (Get-Variable -name $jbtmp -ValueOnly)[1..((Get-Variable -name $jbtmp -ValueOnly).Count-1)]){
        
        $item = ($item.trim()).split("~")
        
        $jbhash = @{}
        $jbhash =  @{
            "Slot" = (((($tmp2 -match $item[1])[0]).trim()) -replace "\s+",";").split(";")[0] -replace ":",""
            "Pool" = $item[0]
            "Barcode" = $item[1]
            "Expires" = $item[2]
            "Used" = $item[4]
            "Location" = $item[3]
            "VolumeID" = (((($tmp2 -match $item[1])[0]).trim()) -replace "\s+",";").split(";")[4]
            "Recyclable" = (((($tmp2 -match $item[1])[0]).trim()) -replace "\s+",";").split(";")[5]
        }
    $jbcontainer += New-Object -TypeName PSObject -Property $jbhash
    }
    
    Set-Variable -name $jbtmp -Value $jbcontainer
    
    $jbtmp2 = $jbtmp -replace ":",""

    (Get-Variable -Name $jbtmp -ValueOnly) | Export-Csv "$path\$jbtmp2.csv" -Delimiter ";" -NoTypeInformation -Force

    $i++
}

foreach ($item in $jbblat) {
    $comma = @{$true="";$false=","}[$item -eq $jbblat[-1]]
    $item = $item -replace ":",""
    $attch += "`"$($item).csv`"$comma"
}

cd $path
blat -to $to -subject $subject -body $body -attach $attch