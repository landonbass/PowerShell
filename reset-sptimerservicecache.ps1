#author: landon bass
#clears the timer service cache on the local machine

add-pssnapin microsoft.sharepoint.powershell -ea 0
cls
function reset-sptimerservicecache () {
    try {
        write-host "begin resetting cache..."
        write-host "`tstopping the timer service..."
        $service = get-service | ? {$_.name -eq "sptimerv4"}
        if ($service.status -eq "running") {
            $service | stop-service -force
        }
        write-host "`tgetting guid path to cache folder..."
        $rootpath = "c:\programdata\microsoft\sharepoint\config\"
        $guid = get-spdatabase | ? {$_.type -eq "configuration database"} | select -expandproperty id
        $cachepath = $rootpath + $guid
        if (-not(test-path $cachepath)) {
            throw "$cachepath not found!"
        }
        write-host "`tfound cache folder:" $cachepath
        write-host "`t`tremoving cached configuration objects"
        get-childitem $cachepath -include *.xml -recurse | remove-item
        write-host "`t`tsetting cache.ini to 1"
        set-content ($cachepath + "\cache.ini") "1"
        write-host "`tstarting the timer service..."
        $service | start-service 
    }
    catch {
        write-host -foregroundcolor red "error:" $_
    }
    finally {
        write-host "done resetting cache."
    }
}
reset-sptimerservicecache