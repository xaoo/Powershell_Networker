#----------------------------------------------------------------------
# Name:           duplicate_client_resources.ps1
# Version:        1.0.0.0
# Start date:     06.06.2016
# Release date:   14.06.2016
# Description:    
#
# Author:         George Dicu        
# Department:     Cloud, Backup, RO
#--------------------------------------------------------------------


$hn = hostname

#//////////////////////////////////////////
#CONSTANTS
#//////////////////////////////////////////

#save script path location
$path = "D:\nsr\scripts"

Write-Output "Choose one of the following:
1. Duplicate to new group
2. Duplicate to existing group
"
$choise = Read-Host

Write-Output "Choose usage of skip function:
1. Use skip param in clients comment to ignore duplicating clients resources
2 .Continue without skip fuctions
"
$skip = Read-Host

#//////////////////////////////////////////
#SCRIPT BLOCK
#//////////////////////////////////////////

##########################
#get all group details
##########################
function get_group_details {
    $getgroup = 
@"
print type:nsr group;name:$args
"@

    return $getgroup | nsradmin.exe -i -
}
####################################################
#Get Clients name grom a specific group
####################################################
function get_clients_in_group {
    $clientarray = 
@"
show name
print type:NSR client;group:$args
"@

    $clients = $clientarray | nsradmin.exe -i -

    $allclients = @()

    foreach($client in $clients){
        
        if([string]::IsNullOrEmpty($client)){
            continue
        }

        $allclients += (($client.trim() -replace "name: ","") -replace ";","")

    }
    return $allclients
}

############################################
#Get Clients Details from a specific group
############################################
function get_clients_details {
    [CmdletBinding()]
    Param(
      [Parameter(Mandatory=$True,Position=1)]
       [string]$client,
      [Parameter(Mandatory=$True,Position=2)]
       [string]$group
    )

    $clientarray = 
@"
print type:NSR client;name:$client;group:$group
"@
    return $clientarray | nsradmin.exe -i -
}

##########################
#Create Group
##########################
function create_group {
    $creategroup = 
@"
create type:NSR group;name:$args
"@

    $creategroup | nsradmin.exe -i -
}

#######################################
#check if the group already exists
#######################################
function check_group {
    $checkgroup = 
@"
print type:NSR group;name:$args
"@

    $check = $checkgroup | nsradmin.exe -i -

    if ([string]::IsNullOrEmpty($check -match "No resources found for query:")) {
        return $TRUE
    }
    else {
        return $FALSE
    }
}

#######################################
#get same client resource id from multiple groups
#######################################
function get_groups_from_client {
    [CmdletBinding()]
    Param(
      [Parameter(Mandatory=$True,Position=1)]
       [string]$client,
      [Parameter(Mandatory=$True,Position=2)]
       [string]$group
    )

    $clientarray = 
@"
show group
print type:NSR client;name:$client;group:$group
"@

    $groups = $clientarray | nsradmin.exe -i -
    $groups = ($groups.trim()).replace("group:","").replace(",",";").split(";").trim()
    return $groups | ? {$_}
}

#######################################
#update client`s group attr
#######################################
function update_client_group {
    [CmdletBinding()]
    Param(
      [Parameter(Mandatory=$True,Position=1)]
       [string]$client,
      [Parameter(Mandatory=$True,Position=2)]
       [string]$group,
      [Parameter(Mandatory=$True,Position=3)]
       [string]$newgroup
    )

    $clientarray = 
@"
show group
. type:NSR client;name:$client;group:$group
update group:$newgroup
"@

    $clientarray | nsradmin.exe -i -
}


####################
#EXECUTION
####################
switch ($choise) { 
    #Duplicate to new group
    1 {
        Write-Output "Enter the New Group Name you want to duplicate clients into"
        $newgroupname =  Read-Host

        if (check_group $newgroupname) {
            Write-Output "*** The group Already Exists, if you want to duplicate into an existing group, please choose 2nd option. Exiting! ***"
            Return
        }
        else {
            create_group $newgroupname

            Write-Output "*** Enter the Group Name you want to duplicate clients from ***"
            $groupname =  Read-Host

            $clients = get_clients_in_group $groupname

            if ($clients.Contains("No resources found for query:")){

                Write-Output "*** This group:$groupname is empty! ***"
                return
            }

            $array = @()

            foreach($client in $clients) {

                Write-Output "*** Copy Client: $client into Group: $newgroupname... ***"

                $container = [System.Collections.Generic.List[System.Object]](get_clients_details $client $groupname)
                $array = get_clients_details $client $groupname

                $container = [System.Collections.Generic.List[System.Object]]($container -replace "type: NSR client;","create type: NSR client;")
                
                if ($skip -eq 1) {
                    
                    $comment = ($container -match "comment:").trim()
                
                    if ($comment.Contains("skip")){

                        Write-Output "*** Skiping $client, skip pram fround in it`s comment field***"
                        continue
                    }
                }

                #get group attribute index range then delete it from $container
                [int]$x = $array.IndexOf(($array -match "group:"))
                [int]$y = $array.IndexOf(($array -match "    save set:"))

                #if we don`t have multiple lines for group attr then skip
                if (!($y-$x -eq 1)) {
                    $container.RemoveRange(($x+1),($y-$x-1))
                }
                
                #get statistics attribute index no. then delete it from $container
                [int]$statistics = $array.IndexOf(($array -match "statistics:"))
                $container.RemoveRange($statistics,2)
                
                ##get client id attribute index no. then delete it from $container
                [int]$clientid = $array.IndexOf(($array -match "client id:"))
                $container.RemoveRange($clientid,2)

                $container = [System.Collections.Generic.List[System.Object]]($container -replace ($container -match "group:"),"group: $newgroupname;")



                $container | nsradmin.exe -i -
            }
        }
    }
    #Duplicate to an existing group
    2 {
        Write-Output "*** Enther the Group Name you want to duplicate clients FROM ***"
        $groupname = Read-Host

        Write-Output "*** Enther the Group Name you want to duplicate clients INTO ***"
        $newgroupname = Read-Host

        $clients = get_clients_in_group $groupname

        if ($clients.Contains("No resources found for query:")){

            Write-Output "This group:$groupname is empty!"
            return
        }

        $array = @()

        foreach($client in $clients) {
            
            $container = [System.Collections.Generic.List[System.Object]](get_clients_details $client $groupname)
            
            if ($skip -eq 1) {
                    
                $comment = ($container -match "comment:").trim()
                
                if ($comment.Contains("skip")){

                    Write-Output "*** Skiping $client, skip pram fround in it`s comment field***"
                    continue
                }
            }

            Write-Output "*** Removing: $newgroupname from Client: $client so we can copy with new Resource ID***"

            #get the groups that the clients has then remove 
            $groups = [System.Collections.Generic.List[System.Object]](get_groups_from_client $client $groupname)

            #if the clients is assinged to the group you want to duplicate into, remove the group from it so we can copy it
            if ($groups.Contains($newgroupname)){
                $groups.RemoveAt($groups.IndexOf(($groups -match $newgroupname)))
            }

            #empty update info every time
            $update = ""
            #prepare string to update the client`s group
            $groups | % { $update += $_ + @{$true="";$false=","}[($groups.Count-1) -eq ($groups.IndexOf($_))] }

            #update the client resource
            update_client_group $client $groupname $update

            Write-Output "*** Copy Client: $client into Group: $newgroupname... ***"

            $container = [System.Collections.Generic.List[System.Object]](get_clients_details $client $groupname)
            $array = get_clients_details $client $groupname

            $container = [System.Collections.Generic.List[System.Object]]($container -replace "type: NSR client;","create type: NSR client;")
                
            #get group attribute index range then delete it from $container
            [int]$x = $array.IndexOf(($array -match "group:"))
            [int]$y = $array.IndexOf(($array -match "    save set:"))

            #if we don`t have multiple lines for group attr then skip
            if (!($y-$x -eq 1)) {
                    $container.RemoveRange(($x+1),($y-$x-1))
                }

            #get statistics attribute index no. then delete it from $container
            [int]$statistics = $array.IndexOf(($array -match "statistics:"))
            $container.RemoveRange($statistics,2)
                
            ##get client id attribute index no. then delete it from $container
            [int]$clientid = $array.IndexOf(($array -match "client id:"))
            $container.RemoveRange($clientid,2)

            $container = [System.Collections.Generic.List[System.Object]]($container -replace ($container -match "group:"),"group: $newgroupname;")

            $container | nsradmin.exe -i -
        
    }
}
    default {Write-Output "*** Please choose 1 or 2! ***"}
}
