#author: landon bass
#analyzes a publishing page to determine web parts counts (closed, audiences, cqwp, etc.)

add-pssnapin microsoft.sharepoint.powershell -ea 0
[void][system.reflection.assembly]::loadwithpartialname("microsoft.sharepoint.publishing")
cls

$url         = ""
$libraryName = "pages"
$pageName    = "default.aspx"

function verify-spwebparts (
    [parameter(mandatory=$true)]
    $url,
    [parameter(mandatory=$true)]
    $libraryName,
    [parameter(mandatory=$true)]
    $pageName
) {
    $assignment = start-spassignment
    try {
        $web = $assignment | get-spweb $url
        $webPublish =  [Microsoft.SharePoint.Publishing.PublishingWeb]::GetPublishingWeb($web)
        $page = $webPublish.getpublishingpage("/" + $libraryName + "/" + $pageName)
        $mgr = $web.getlimitedwebpartmanager($page.url, [system.web.ui.webcontrols.webparts.personalizationscope]::shared)
        $webParts = $mgr.webparts
        
        $custom  = 0
        $closed  = 0
        $aud     = 0
        $cqwp    = 0
        $cqwpAud = 0
        $total   = $webParts.count
        
        $webParts | % {
            $type = $_.gettype()
            if ($type.assembly.fullname -notlike "microsoft*") {
                $custom++
            }
            if ($_.isclosed) {
                $closed++
            }
            if ($_.authorizationfilter -ne "") {
                $aud++
            }
            if ($type.name -eq "ContentByQueryWebPart") {
                $cqwp++
                if ($_.filterbyaudience) {
                    $cqwpAud++
                }
            }  
        }
        
        write-host "analyzed" $page.Title "-" $page.url
        write-host "`t$total web parts on the page"       
        write-host "`t`t$custom web parts are custom or third party"
        write-host "`t`t$closed web parts are closed"
        write-host "`t`t$aud web parts are targeted to audiences"
        write-host "`t`t$cqwp are content query web parts"
        write-host "`t`t$cqwpAud are content query web parts that filter on audiences"
        
    
    } catch {
        write-host -foregroundcolor red "error:" $_ 
    } finally {
        stop-spassignment $assignment
    }
}

verify-spwebparts -url $url -libraryName $libraryName -pageName $pageName