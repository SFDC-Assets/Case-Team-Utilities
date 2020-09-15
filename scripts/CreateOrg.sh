#!/bin/bash
readonly orgAlias="CaseTeamScratch"
readonly devHubUserName="MyComponents"

echo "*** Creating scratch org ..."
sfdx force:org:create \
    --definitionfile config/project-scratch-def.json \
    --type scratch \
    --nonamespace \
    --targetdevhubusername "$devHubUserName" \
    --setdefaultusername \
    --setalias "$orgAlias" \
    --durationdays 30 \
    --loglevel error || exit 1
echo "*** Pushing metadata to scratch org ..."
sfdx force:source:push || exit 1
echo "*** Assigning permission set to your user ..."
sfdx force:user:permset:assign --permsetname Case_Team_Utilities --loglevel error
echo "*** Setting time zone for your user ..."
sfdx force:data:record:update --sobjecttype User --where "Name='User User'" --values "TimeZoneSidKey='America/New_York'" --loglevel error
echo "*** Generating password for your user ..."
sfdx force:user:password:generate --targetusername "$orgAlias" --loglevel error