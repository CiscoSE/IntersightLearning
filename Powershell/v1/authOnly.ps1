<#
.NOTES
Copyright (c) 2022 Cisco and/or its affiliates.
This software is licensed to you under the terms of the Cisco Sample
Code License, Version 1.0 (the "License"). You may obtain a copy of the
License at
               https://developer.cisco.com/docs/licenses
All use of the material herein must be in accordance with the terms of
the License. All rights not expressly granted by the License are
reserved. Unless required by applicable law or agreed to separately in
writing, software distributed under the License is distributed on an "AS
IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
or implied.

.PARAMETER ApiKeyID
You must obtain a key ID and provide it to the script in quotes. To obtain a key ID:
    - Got to intersight.com and logon. 
    - Once logged in, select the gear in the upper right hand corner and select Settings
    - Select API keys
    - Select Generate API Key
    - Save the private key to a file. 
    - record the API Key ID
Use the key id in quotes for this variable.

.PARAMETER ApiKeyFilePath
You must obtain a private key file and provide a path to the file in quotes. To obtain a private key file:
    - Got to intersight.com and logon. 
    - Once logged in, select the gear in the upper right hand corner and select Settings
    - Select API keys
    - Select Generate API Key
    - Save the private key to a file. 
    - record the API Key ID
Use the path to the key file in quotes with this variable to tell the scipt where to get the private key.
.DESCRIPTION
This is an example demo script that shows how to pull basic data about systems from Intersight using Powershell.
The output will be saved to a file called test.html, with data retrieved also sent to the screen. 
#>
[cmdletbinding()]
param(
    [string]$intersightAddress = "https://intersight.com",
    [parameter(mandatory=$true)][string]$ApiKeyID,
    [parameter(mandatory=$true)][string]$ApiKeyFilePath

)
# This the module required for Intersight
import-module Intersight.PowerShell

# Basic formating for the header of the HTML. 
$CSS = @"
<Title>Memory Error TAC Report</Title>
<Style type='text/css'>
SrvProp{
    boarder:20pt;
}

td, th { border:0px solid black; 
     border-collapse:collapse;
     white-space:pre; }
th { color:white;
 background-color:black; }
table, tr, td, th { padding: 2px; margin: 0px ;white-space:pre; }
tr:nth-child(odd) {background-color: lightgray}
table { width:95%;margin-left:5px; margin-bottom:20px;}

</Style>
"@

# We use a very simple hash table for our authentication parameters.
$onprem = @{
    BasePath = "https://intersight.com"
    ApiKeyId = $ApiKeyID
    ApiKeyFilePath = $ApiKeyFilePath
    HttpSigningHeader =  @("(request-target)", "Host", "Date", "Digest")
}
#Then we pass those parameters to an Intersight command that registers them so that other commands can use them.
Set-IntersightConfiguration @onprem

#Now we should be able to get a list of systems. Where you created your API key will determine the group of systems that gets returned.
$listOfSystems = Get-IntersightComputePhysicalSummary

#This defines an array we will use to collect a list of system properties.
$finalList = @()

# This function will be used later to return just the KVM IP address from a list of KVM IP addresses.
function get-kvmip {
    param(
        $kvmip
    )
    return $(($kvmip | ?{$_.name -eq "Outband"}).address)

}
# Loop through the list we got earlier
$listOfSystems | %{
    #For each item in the list, collect properties. 
    $oneItem = New-Object PSObject -Property @{
        name = $_.name                                          # The name of the system
        moid = $_.moid                                          # The Moid we use if we want to take actions against a system through the API
        model = $_.model                                        # The model of the device
        serial = $_.serial                                      # The serial number of the device
        firmware = $_.firmware                                  # The firmware version of the device
        MgmtIpAddress = $_.MgmtIpAddress                        # The CIMC or FI Management IP to connect to the management
        OutOfBandKVM = get-kvmip -kvmip $_.kvmipaddresses       # The Out of Band KVM, which we get from the previous function we defined earlier.
    }
    #For each item we find, we add it to the list.
    $FinalList += $oneItem
}
#If we find any devices
if ($FinalList.count -gt 0){
    #output to the screen
    $finalList | ft
    # Write it out to an HTML file
    $FinalList | select name,model,MgmtIpAddress,serial,moid,OutOfBandKVM | ConvertTo-Html -As Table -head $CSS | Out-File test.html
}
else {
    # if nothing is found, we just say we found nothing.
    write-host "Nothing Captured"
}
