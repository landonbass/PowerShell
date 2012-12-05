#author: landon bass (and todd carter - http://todd-carter.com/post/2012/01/31/when-page-output-caching-does-not-output)
#creates a sql statement to count uniquely secured items in a site collection
#can also attempt to execute the script
#if the result is greater than 10,000 then object caching will not work


add-pssnapin microsoft.sharepoint.powershell -ea 0 
cls
$url = ""

function verify-spobjectcachelimit (
    [parameter(mandatory=$true)]
    $url,
    [bool]$execute
) {
    $assignment = start-spassignment
    try {
        $site = $assignment | get-spsite $url
        $siteid = $site.id
        $server = $site.contentdatabase.server
        $dbname = $site.contentdatabase.name
        #suspect to sql injection, use with caution
        $sql = "--server:" + $server + "`nuse $dbname" + "`nselect count(scopeurl) from tvf_perms_site('$siteid')"
        if ($execute) {
            $connection = new-object data.sqlclient.sqlconnection "server=$server;integrated security=true"
            $command = new-object system.data.sqlclient.sqlcommand($sql, $connection)
            $dataset = new-object system.data.dataset
            $dataadapter = new-object system.data.sqlclient.sqldataadapter($command)
            $dataadapter.fill($dataset) | out-null
            $connection.close()
            return $dataset.tables[0].rows[0][0]
        } else {
            return $sql
        }
    }
    catch {
        write-host -foregroundcolor red "error: $_"
    }
    finally {
        stop-spassignment $assignment
    }
}

verify-spobjectcachelimit -url $url -execute $false