#!/bin/bash

sfdx force:package:create \
    --packagetype "Unlocked" \
    --nonamespace \
    --name "Case Team Utilities" \
    --description "This package contains code and metadata for the Salesforce Case Team Utilities" \
    --path "force-app" \
    --targetdevhubusername "MyComponents"