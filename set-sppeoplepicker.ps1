#author:landon bass
#sets the people picker settings for site collections

add-pssnapin microsoft.sharepoint.powershell -ea 0
cls
$url           = ""  #leave blank for all web apps
$pickerSetting = ""  #use "" to reset to default


function set-sppeoplepicker (
     $webapplication,
     [parameter(mandatory=$true)]
     $pickerSetting
 ) {
    $assignment = start-spassignment
    try {
        
        if ($url -eq "") {
            #do all web apps but CA
            get-spwebapplication | % {
                $wa = $_
                $wa | get-spsite -assignmentcollection $assignment -limit all | % {
                        $site = $_
                        set-spsite $site -useraccountdirectorypath $pickerSetting
                        write-host $wa.name  " " $site.url "done"
                }
            }
         } else {
              get-spwebapplication $url | % {
                    $wa = $_
                    $wa | get-spsite -assignmentcollection $assignment -limit all | % {
                        $site = $_
                        set-spsite $site -useraccountdirectorypath $pickerSetting
                        write-host $wa.name  " " $site.url "done"
                    }
              }
         }
    } catch {
        write-host -foregroundcolor red "error:" $_
    } finally {
        stop-spassignment $assignment
    }
 }
 
 set-sppeoplepicker -url $url -pickerSetting $pickerSetting
