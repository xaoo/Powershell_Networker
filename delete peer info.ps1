
[CmdletBinding()]
Param(
  [Parameter(Mandatory=$True,Position=1)]
   [string]$client
)
#$clients = Get-Content "C:\temp\clients"

$i = 1

#Client Side
$nsrdpi = 
@"
delete type:NSR peer information;name:abackup4.bane.dk
"@

#delete Peer Info from client side
$nsrdpi | nsradmin.exe -p nsrexecd -s $client -i -
Write-Output "***Client side Peer deleted for: $client "
#Server Side

$nsrdpi =
@"
delete type:NSR peer information;name:$client
"@

#delete Peer Info from seerver side
$nsrdpi | nsradmin.exe -p nsrexecd -s abackup4.bane.dk -i -
Write-Output "***Server side Peer deleted for: $client "
write-output "************************$i LEFT TO DELETE************************"  
$i++