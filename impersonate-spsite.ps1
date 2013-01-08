#author: landon bass
#get a spsite object using the token of a specified user, "impersonating" the object

add-pssnapin microsoft.sharepoint.powershell -ea 0
cls

#use global so everything gets disposed
start-spassignment -global

function get-impersonatedsite (
    [parameter(mandatory=$true)]
    $url,
    [parameter(mandatory=$true)]
    $username
)
{
    try {
        $site = get-spsite $url -ea 0
        if ($site -eq $null) {
            throw "site not found: $url"
        }
        $web = $site.rootweb
        $user = $web.allusers[$username]
        if ($user -eq $null) {
            throw "user not found: $username"
        }
        $token = $user.usertoken
        $isite = new-object microsoft.sharepoint.spsite($url, $token)
        return $isite
    }
    catch {
        write-host "error:" $_
    }
 }
 
try {
    $s = get-impersonatedsite -url:"<<url>>" -user:"<<domain\username>>"
    #do something as that user with $s
}
catch {
    write-host "error:" $_
}
finally {
    stop-spassignment -global
}
