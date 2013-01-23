#deletes user profiles with a certain prefix, i.e. domain
#author: landon bass
add-pssnapin microsoft.sharepoint.powershell -ea 0
cls

#url of site collection associated with UPSA
$url = "<url>"
#start of profiles, example "abc\*", note the wildcard
$prefix = "<domain>\*"   
#if true, doesn't delete profiles
$whatif = $true
                
function delete-userprofiles (
    [parameter(mandatory=$true)]
    $url,
    [parameter(mandatory=$true)]
    $prefix,
    [parameter(mandatory=$true)]
    $whatif
)
    {
    $assignment = start-spassignment
    try {
        $site = get-spsite $url
        $ctx = get-spservicecontext $site
        $mgr = new-object microsoft.office.server.userprofiles.userprofilemanager($ctx)
        $mgr.getenumerator() | % {
            $account = $_[[microsoft.office.server.userprofiles.propertyconstants]::accountname].value 
            if ($account -like $prefix) {
                if ($whatif) {
                    write-host "$account would be deleted"
                } else{
                    $mgr.removeuserprofile($account)
                    write-host "$account deleted"
                }
            }
        } 
    }
    catch {
        write-host -foregroundcolor red "error:" $_
    }
    finally {
        stop-spassignment $assignment
    }
}

delete-userprofiles -url:$url -prefix:$prefix -whatif:$whatif
