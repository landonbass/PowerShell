#author: landon bass
#wraps stsadm -o sync -listolddatabases 1 to see how many content databases need to be synced
cls
function verify-spuilsync () {
  try {
        $output = cmd /c "stsadm -o sync -listolddatabases 1"
        $dbCount = 0
        $output | % {
            if ($_ -like "ID: *") {
                $dbCount++
            } 
        }
        if ($dbCount -gt 0) {
            write-host "$dbCount content databases need to be synced"
        }
    }
    catch {
        write-host -foregroundcolor red "error:" $_
    }
}

verify-spuilsync
