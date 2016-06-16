<#
    author: landon bass

    this function will check all lookup fields to ensure that the lists exist on the site
    if you look at a look field in the ui and it it does not show which list it is tied to
    that may mean the lookup is broken, such as someone deleting and creating a list, which would create a new list id
#>
$url = "<<ENTER SITE URL>>"

function verify-lookupfields {
    param (
        [parameter(mandatory=$true)]
        $url
    )
    begin {
        add-pssnapin "microsoft.sharePoint.powershell" -ea 0
    }
    process {
        $assignment = start-spassignment
        $results = @()
        try {
            $web = get-spweb -assignmentcollection $assignment $url
            $web.fields | ? {$_.type -eq "lookup" <# also gets schema type lookupmulti #> } | % {
                $field = $_
                try {
                    $schema     = [xml]$field.schemaxml
                    #SPField.lookuplist does not seem to be set for some OOTB fields, so we will pull it from schema xml
                    $schemaList = $schema.field.list
                    $isHidden   = [system.convert]::toboolean($schema.field.group -eq "_hidden")
            
                    #some OOTB people fields have no list set, we will assume all _hidden group are OOTB and we will skip them for now
                    #you can remove this check to verify these fields
                    #as long as it is not in the hidden group, which some fields appear to work differently
                    #these fields are typically user fields that get tied to the user information list
                    if ([string]::isnullorempty($schemaList) -and $isHidden) {
                        return 
                    }

                    #also, it can reference "self", either added as a list column or 'late bindable' as a site column and refers to the parent list
                    #or "userinfo" which is the siteuserinfolist
                    #or "docs" which references columns in the allsdocs table in the content database
                    #or "appprincipals, which ties to users who create/modify apps
                    if ($schemaList -in ("self", "userinfo", "docs", "appprincipals")) {
                        return 
                    }

                    #some columns store list name, some list url (lists/name), some id, we need to parse
                    $isGuid  = $schema.field.list -match("^(\{){0,1}[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}(\}){0,1}$")
                    $listRef = $null
                    if ($isGuid) {$listRef = ([guid]$schema.field.list)} else {$listRef = $schema.field.list}
                    $list = $null
                    if ($isGuid -or -not $listRef.startswith("lists/")){ $list = $web.lists[$listRef]} else { $list = $web.getlistfromurl($listRef)}
                    if ($list -ne $null) { return }
            
                    $result = new-object psobject
                    $result | add-member -membertype noteproperty -name "InternalName"  -value $field.internalname
                    $result | add-member -membertype noteproperty -name "Title"         -value $field.title
                    $result | add-member -membertype noteproperty -name "ListReference" -value $listRef

                    $results += $result
                }
                catch {
                    write-host -foregroundcolor red ("error reading field " + $field.title + " with internal name " + $field.intername)
                }
            }
        }
        catch {
            write-host -foregroundcolor red $_
        }
        finally {
            stop-spassignment $assignment
        }
        return $results
    }
}
verify-lookupfields $url | out-gridview
