#author: landon bass
#verifies features without a scope, which have been caused during orphaned deployments
add-pssnapin microsoft.sharepoint.powershell -ea 0

cls

function verify-spfeaturescope () {
    try {
        get-spfeature | ? {$_.scope -eq "" -or $_.scope -eq $null} | % {
            $name = $_ | select -expandproperty displayname
            $id   = $_ | select -expandproperty id
            write-host "feature with id: $id and name: $name has an invalid scope"
        }
    }
    catch {
    }
}

verify-spfeaturescope