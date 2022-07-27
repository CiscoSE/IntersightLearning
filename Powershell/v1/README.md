If this is your first time running a PowerShell script against Intersight, this is one of the safest to start out with because it changes nothing. This script will output some basic data about systems in Intersight and convert that data into a file in HTML format. 
```
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
```