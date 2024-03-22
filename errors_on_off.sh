#!/bin/bash
# Controller authentication data
controllerHost="" # Has to have https:// in it
account=""  # The Controller Account Name
apiclient="" # The API Client Created in the Administration section in the Controller
secret="" # The API Clien secret

applicationId=0 # Choose the application for which you want to create the Action Suppression - ID Taken from the URL when in the Application UI in the Controller

# Generate the barer token
rawToken=$(curl -s -H "Content-Type: application/x-www-form-urlencoded" -d "grant_type=client_credentials&client_id=$apiclient@$account&client_secret=$secret" "$controllerHost/controller/api/oauth/access_token");

# Verify authentication
if [[ $rawToken =~ "access_token" ]]; then
  rawToken=$(echo $rawToken | sed 's/{\"access\_token\"\: \"//');
  token=$(echo $rawToken | sed 's/\".*//');
else
  echo "ERROR: Failed to Authenticate, check API User Secret and Connection";
  exit 1;
fi

echo "Created Bearer Token";

echo "Preparing the JSON for update"

# Below, change the variable "markTransactionAsErrorOnErrorMessageLog" to true or false as needed
# true if the app should collect the error snapshots
# false if the app should stop collecting error snapshots
tmp_json='{
  "id": 0,
  "version": 0,
  "ignoreExceptions": [],
  "ignoreLoggerNames": [],
  "customerLoggerDefinitions": [],
  "httpErrorReturnCodes": [],
  "errorRedirectPages": [],
  "disableJavaLogging": false,
  "disableLog4JLogging": false,
  "disableDefaultHTTPErrorCode": false,
  "ignoreExceptionMsgPatterns": [],
  "captureLoggerErrorAndFatalMessages": true,
  "ignoreLoggerMsgPatterns": [],
  "maxFramesInRootCause": 5,
  "stackTraceLineLimit": 0,
  "markTransactionAsErrorOnErrorMessageLog": true, 
  "disableSLF4JLogging": false,
  "entityErrorConfigurations": null
}'

# Updated Error Config POSTed
echo "Updated Error Config Posted"
response=$(curl -X POST -s -H "Authorization:Bearer $token" -H "Content-Type: application/json" --data "$tmp_json" "$controllerHost/restui/errorDetection/updateErrorConfig?applicationId=$applicationId")

if [[ $response != "" ]]; then
  echo "POST Failed";
else
  echo "POST Succesfull";
fi
