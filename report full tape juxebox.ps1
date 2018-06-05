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
$body = "Hello,||This is an automated tape status report on Library $($jb.name)||RO Backup Team"

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
    Set-Variable -name $jb.Name -Value (mminfo -q "family=tape,location=$jbtmp" -r "pool,barcode,volretent,location,%used")
    
    $tmp = @()
    $tmp2 = @()
    #saveing current jukebox 
    $tmp2 = nsrjb -j $jb.Name
    $tmp2 = $tmp2[3..($tmp2.count-1)]
    $jbcontainer = @()
    
    #Fast Inventory Robot
    if($fastinventory){
        nsrjb -j $jb.Name -IIq
    }
    
    
    foreach($item in (Get-Variable -name $jb.name -ValueOnly)[1..((Get-Variable -name $jb.name -ValueOnly).Count-1)]){
        
        $item = ($item.trim() -replace "\s+",";").split(";")
        
        $jbhash = @{}
        $jbhash =  @{
            "Slot" = (((($tmp2 -match $item[1])[0]).trim()) -replace "\s+",";").split(";")[0] -replace ":",""
            "Pool" = $item[0]
            "Barcode" = $item[1]
            "Expires" = $item[2]
            "Location" = $item[3]
            "Used" = $item[4]
        }
    $jbcontainer += New-Object -TypeName PSObject -Property $jbhash
    }
    
    Set-Variable -name $jb.Name -Value $jbcontainer
    
    $i++
    
    (Get-Variable -Name $jb.name -ValueOnly) | Export-Csv "D:\Legato\nsr\SCRIPTS\$($jb.name).csv" -Delimiter ";" -NoTypeInformation -Force

}

foreach ($item in $jbblat) {
    $comma = @{$true="";$false=","}[$item -eq $jbblat[-1]]
    $attch += "`"$($item).csv`"$comma"
}

blat -to $to -subject $subject -body $body -attach $attch