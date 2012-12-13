#author: landon bass
#verifies that the search query and site settings service is running only on query components
#does sp enterprise search, not FAST

add-pssnapin microsoft.sharepoint.powershell -ea 0

cls

function verify-spsearchqueryservice () {
    try {
        $onlineServers = get-spserviceinstance | ? {$_.typename -eq "Search Query and Site Settings Service" -and $_.status -eq "online"} | select -expandproperty server
        $offlineServers = get-spserviceinstance | ? {$_.typename -eq "Search Query and Site Settings Service" -and $_.status -ne "online"} | select -expandproperty server
        $queryServers = @()
        get-spserviceapplication | ? {$_.typename -eq "Search Service Application" -and $_.defaultsearchprovider -eq "sharepointsearch"} | % {
            $_.querytopologies | select -expandproperty querycomponents | % {
                $_ | ? {$_.state -eq "ready"} | % {
                    if ($queryServers -notcontains $_.servername) {
                        $queryServers += $_.servername
                    }
                }
            }
        }
        $onlineServers | % {
            $server = $_.name
            if ($queryServers -notcontains $server) {
                write-host "search query and site settings service is running on $server, which is not a query server"
            }
        }
        $offlineServers | % {
            $server = $_.name
            if ($queryServers -contains $server) {
                write-host "search query and site settings service is not running on $server, which is a query server"
            }
        }
    }
    catch {
        write-host -foregroundcolor red "error:" $_
    }
}

verify-spsearchqueryservice
