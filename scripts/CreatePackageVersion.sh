#!/bin/bash

sfdx force:package:version:create \
    --installationkeybypass \
    --wait 10 \
    --package "Case Team Utilities" \
    --path "force-app" \
    --targetdevhubusername "MyComponents"