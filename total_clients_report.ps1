$nsrclients = 
@"
. type: NSR client
show name
print
"@
#save nsradmin output after execution
$nsrclients = $nsrclients | nsradmin.exe -i -
$clients = @()


foreach ($client in $nsrclients[1..(($nsrclients.Count)-1)]) {
    if ([string]::IsNullOrEmpty($client)){
        continue
    }
    else {
        $clients += ($client.trim()).split(":")[1].trim().split(";")[0]
    }
}
$date = date -format "dd_MM_yyyy"

New-PSDrive –Name “Q” –PSProvider FileSystem –Root “\\149.212.20.216\NetworkerData” –Persist

$clients | select -Unique | set-content Q:\clients_$date.txt