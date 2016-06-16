PowerShell Scripts 
==========

Various PowerShell scripts that I have written/modified. Most are geared towards SharePoint.

##delete-userprofiles
deletes user profiles with a certain prefix, i.e. domain

##enable-developerdashboardforadmins
turns on developer dashboard, but only for full control

##get-spserverbyrole
returns servers in a farm based on type (web application, central admin, database)
i use this when checking server settings / artifacts based on role (i.e. deploy pdf icon to servers hosting
web applications)

##impersonate-spsite
gets a spsite object using the token of a specified user, "impersonating" the object

##reset-sptimerservicecache
clears the timer service cache on the local server by stopping sptimerv4, clearing the xml files
that represent objects in the config db, setting the ini file to 1, and restarting the service

##set-sppeoplepicker
sets people picker properties to limit lookup

##verify-lookupfields
parses lookup field schemas in a site to ensure the referenced list exists

##verify-loopbackcheck
verifies that loopback has been disabled through the registry

##verify-spfeaturescope
checks for features that do not have a scope specified. i have seen this occur numerous times with custom 
features, which can cause orphaned items in the config db and/or filesystem

##verify-spoutputcachelimit
this is an enhancement on a todd carter blog post (see script comments for url) that checks the number
of uniquely secured items in a site collection to verify if output cache will function. it can output the sql statement that needs to be run, or
it can attempt to execute it itself

##verify-spsearchqueryservice
verifies that the search query and site settings service is running and running only on query components

##verify-spuilsync
wraps stsadm -o sync -listolddatabases 1 to see how many content databases need to be synced

##verify-spwebapplicationportalaccounts
checks each web application (except ca) to verify that the portal superuser and superreader accounts are set

##verify-spwebparts
checks a publishing page for potential web part performance issues (custom, closed, audience, cqwp, cqwp with/audience filtering, etc.)
this will not work in foundation
