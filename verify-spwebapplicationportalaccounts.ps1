#author: landon bass
#verifies that content web applications have portalsuperuser and portalsuperreader set
add-pssnapin microsoft.sharepoint.powershell -ea 0

cls


function verify-spwebapplicationportalaccounts () {
    try {
        $webapplications = get-spwebapplication
        $webapplications | % {
            if ($_.properties["portalsuperuseraccount"] -eq $null -or $_.properties["portalsuperreaderaccount"] -eq $null) {
                $name = $_ | select -expandproperty name
                write-host "$name has missing portal accounts"
            }
        }
    }
    catch {
    }
}

verify-spwebapplicationportalaccounts