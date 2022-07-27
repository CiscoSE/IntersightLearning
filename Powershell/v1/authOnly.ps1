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
param()
import-module Intersight.PowerShell

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

$onprem = @{
    BasePath = "https://intersight.com"
    ApiKeyId = "599cbe58f11aa10001311788/599cbdf1f11aa10001310c54/62e14ba37564612d3314495e"
    ApiKeyFilePath = "/demo/.ssh/IntersightAPIPrivateKey.txt"
    HttpSigningHeader =  @("(request-target)", "Host", "Date", "Digest")
}
Set-IntersightConfiguration @onprem

Get-IntersightConfiguration

$listOfSystems = Get-IntersightComputePhysicalSummary

$finalList = @()
function get-kvmip {
    param(
        $kvmip
    )
    return $(($kvmip | ?{$_.name -eq "Outband"}).address)

}

$listOfSystems | %{
    $oneItem = New-Object PSObject -Property @{
        name = $_.name
        moid = $_.moid
        model = $_.model
        serial = $_.serial
        firmware = $_.firmware
        MgmtIpAddress = $_.MgmtIpAddress
        #OutOfBandKVM = $({($_.kvmipaddresses | ?{$_.name -eq "Outband"}).address})
        OutOfBandKVM = get-kvmip -kvmip $_.kvmipaddresses
    }
    $FinalList += $oneItem
}

$FinalList | select name,model,MgmtIpAddress,serial,moid,OutOfBandKVM | ConvertTo-Html -As Table -head $CSS | Out-File test.html

