#author: landon bass
#returns servers of different types (web, database, ca, etc.)
#since spserver.role can be misleading
#note: some servers can serve multiple roles
#returns objects of spserver type

#role must be one of the following: web, ca, db
$role = "ca"

add-pssnapin microsoft.sharepoint.powershell -ea 0
cls
function get-spserverbyrole (
    [parameter(mandatory=$true)]
    $role
) {
    try {
        if ($role -eq "web") {
            return get-spserviceinstance | ? {$_.typename -eq "microsoft sharepoint foundation web application" -and $_.status -eq "online"} | select -expandproperty server
        }
        if ($role -eq "ca") {
            return get-spserviceinstance | ? {$_.typename -eq "central administration" -and $_.status -eq "online"} | select -expandproperty server
        }
        if ($role -eq "db") {
            return get-spserver | select -expandproperty serviceinstances | ? {$_.typename -eq "microsoft sharepoint foundation database" } | select -expandproperty server
        }
        
        throw "role $role not in (web, ca, db)"
    }
    catch {
        write-host -foregroundcolor red "error:" $_
    } 
}

get-spserverbyrole -role $role 