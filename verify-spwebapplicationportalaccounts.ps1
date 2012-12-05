#author: landon bass
#verifies that content web applications have portalsuperuser and portalsuperreader set

#two potential issues:
#1 - only checks permissions on all zones. if you specify based on zone you will need to modify the logic
#2 - does not check to see if reader has more than read permissions, which can lead to unexpected results


add-pssnapin microsoft.sharepoint.powershell -ea 0

cls


function verify-spwebapplicationportalaccounts () {
    try {
        $webapplications = get-spwebapplication
        $webapplications | % {
            $name = $_ | select -expandproperty name  
            $user = $_.properties["portalsuperuseraccount"] 
            $reader = $_.properties["portalsuperreaderaccount"]
            if ($user -eq $null) {
                write-host "$name is missing portalsuperuser account"
            } else {
                [bool]$fullcontrol = $false
                $_.policies  | ? {$_.username -eq $user} | % {
                    $_.policyrolebindings | % {
                        if ($_.type -eq "fullcontrol") {
                            $fullcontrol = $true
                        }
                    }
                }
                if (-not $fullcontrol) {
                    write-host "$user does not have fullcontrol on $name"
                }
            }
            if ($reader -eq $null) {
                $name = $_ | select -expandproperty name
                write-host "$name is missing portalsuperreader account"
            } else {
                [bool]$read = $false
                $_.policies  | ? {$_.username -eq $reader} | % {
                   $_.policyrolebindings | % {
                        if ($_.type -eq "fullread") {
                            $read = $true
                        }
                    }
                }
                if (-not $read) {
                    write-host "$reader does not have read on $name"
                }
            }
        }
    }
    catch {
    	write-host -foregroundcolor red "error:" $_
    }
}

verify-spwebapplicationportalaccounts