[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$srv
)
Write-Output "--------------------------------"
Write-Output "Checking ping on $srv"
Write-Output "--------------------------------"
PING.EXE $srv
Write-Output "--------------------------------"
Write-Output "Checking RPC Ports"
Write-Output "--------------------------------"
nsrrpcinfo.exe -p $srv
Write-Output "--------------------------------"
Write-Output "Checking Ports"
Write-Output "--------------------------------"
nsrports.exe -s $srv
Write-Output "--------------------------------"
Write-Output "Checking Remote Agents"
Write-Output "--------------------------------"
$nsr = 
@"
. type: NSR remote agent
print
"@
#save nsradmin output after execution
$nsr | nsradmin.exe -p nsrexecd -s $srv -i -
Write-Output "--------------------------------"
Write-Output "Details about $srv"
Write-Output "--------------------------------"
$nsr = 
@"
. type: NSRLA
print
"@
#save nsradmin output after execution
$nsr | nsradmin.exe -p nsrexecd -s $srv -i -