 # To get the metadata of the Instance
 $Proxy=New-object System.Net.WebProxy
 $WebSession=new-object Microsoft.PowerShell.Commands.WebRequestSession
 $WebSession.Proxy=$Proxy
 Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET -Uri "http://169.254.169.254/metadata/instance?api-version=2021-02-01" -WebSession $WebSession | ConvertTo-Json -Depth 64 |out-file c:\metadata.json

 # To get metadata of particular data key 
 $key = Read-Host "Please specify the data key"
 $value= Invoke-RestMethod -Headers @{"Metadata"="true"} -Method GET  -Uri "http://169.254.169.254/metadata/instance/compute/$($key)?api-version=2021-01-01&format=text" -WebSession $WebSession
 Write-host "The value for $key is :$value"


 