#----------------------------------------------------------------------
# Name:           add NW clients
# Version:        1.0.0.0
# Author:         George Dicu translated from Groza Dani`s bash script.
# Start date:     20.09.2015
# Release date:   20.09.2015
# Description:    
#
# Author:         
# Department:     Cloud, Backup  
#--------------------------------------------------------------------

$itemlist = Import-Csv C:\clients.txt -header "Hostnames"
 
foreach ($item in $itemlist) {

    $hostname = $item.Hostnames
    $nsradmin_add = ''
    $nsradmin_add = 
@"
create type:NSR client;
name: $hostname;
server:WIN-QCDM64996QS;
comment:script test;
browse policy:Month;
retention policy:Year;
group:Default;
Schedule:Default;
Storage Nodes:nsrserverhost;
"@
    
    $nsradmin_add | nsradmin.exe -i -
}