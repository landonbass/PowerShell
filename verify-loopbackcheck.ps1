#author: landon bass
#checks is loopback is disabled through registry


cls

function verify-loopbackcheck () {
    try {
        $loopBack = get-itemproperty HKLM:\System\CurrentControlSet\Control\Lsa | select -expandproperty disableloopbackcheck -ea 0
        if ($loopBack -ne "1") {
            write-host "loop back is not disabled on $env:computername"
        }
    }
    catch {
        write-host -foregroundcolor red "error:" $_
    }
}

verify-loopbackcheck

