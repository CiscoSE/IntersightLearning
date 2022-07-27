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
#>
[cmdletbinding()]
param(
    [string]$intersightAddress = "https://intersight.com",
    [string]$ApiKeyID,
    [string]$ApiKeyFilePath

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
