#enable developer dashboard for admins

add-pssnapin microsoft.sharepoint.powershell -ea 0
cls
$svc = [microsoft.sharepoint.administration.spwebservice]::contentservice
$dashboard = $svc.developerdashboardsettings
$dashboard.requiredpermissions = [microsoft.sharepoint.spbasepermissions]::fullmask
$dashboard.displaylevel = 'on'
$dashboard.update()


