<#
 .SYNOPSIS
    Test a template based Azure Deployment

 .DESCRIPTION
    deploys web application, and ensures that the parameters supplied match the parameters of the deployed Azure object.

 .PARAMETER ResourceGroup
    Implied variable.   will set this from the Variables visible in the Project.
	The resource group where the Azure object is deployed. 

 .PARAMETER web_hostPlanName
	Name of the Application Service Plan which the application sits upon.

 .PARAMETER web_hostPlanLinux
	The application service plan kind is linux (true or false).

 .PARAMETER web_websiteName
	Name of the Web Application.

 .PARAMETER web_webSocketsEnabled
	Enabling WebSocket

 .PARAMETER web_devLang
	The name of the development language which the application uses.  java or net

 .PARAMETER web_allowedOrigins
	List of allowed origins (CORS) that are permitted.

 .PARAMETER web_appSettings
	List of settings applied to the app. Provided in format "setting1=value,setting2=value"

 .PARAMETER web_connectionStrings
	List of connection strings for the app. Provided in format "constring1=value,&,constring2=value"
	IMPORTANT - The divider for connections strings is ",&," due to the characters used in a database connection string - which may also include server passwords. 

 .PARAMETER web_ipRestrictions
	A comma seperated string of IP address to allow access.
 
 .PARAMETER web_clientAffinity
	Disabling Arr Affinity
#>

#Include Shared Library
. $PSScriptRoot/DeploymentFunctions.ps1

$projectVariables = @{
	"Resource Group"            = $ResourceGroup
	"Project Code"              = $web_projectCode
	"App Service Plan Name"     = $web_hostPlanName
	"App Service Plan is Linux" = $web_hostPlanLinux
	"WebSite Name"              = $web_websiteName
	"Enabling WebSocket"        = $web_webSocketsEnabled
	"Dev Language"              = $web_devLang
	"Allowed Origins"           = $web_allowedOrigins
	"App Settings"              = $web_appSettings
	"Connection Strings"        = $web_connectionStrings
	"ARR affinity"              = $web_clientAffinity

}
Write-Variables -component "Web Application" -variables $projectVariables

#Check if App Sevice Plan is not Linux
if(!$web_hostPlanLinux){
	$web_hostPlanLinux = $false
}

#Convert a single string of multiple allowed origins (CORS) passed, into an array of strings.
$allowedOrigins = @()

foreach ( $origin in $web_allowedOrigins -split "," ) {
	$allowedOrigins += $origin.trim().replace('"',"")
}

#Convert a single string of app settings into a hashtable
$appSettings = @{}


# Only build app settings if there is at least one = sign present in the string.
if (( $null -ne $web_appSettings ) -and ($web_appSettings.contains("="))) {
    foreach ( $appsetting in $web_appSettings -split ";" ) {
        $key,$val = $appsetting.split("=",2)
	    $fromappSettings.Add($key,$val)
    }
}

#Take the key value pairs from the hashtable and place them into an array to be supplied to the arm template. 
$tojsonapplicationSettings = @()
foreach ( $applicationSetting in $fromappSettings.Keys ) {
	$tojsonapplicationSettings += @{name=${applicationSetting};value=$($fromappSettings.Item($applicationSetting))}
}

#Convert a single string of connection strings into a hashtable
$connectionStrings = @{}

# Only build connection strings if there is at least one = sign present in the string.
if (( $null -ne $web_connectionStrings ) -and ($web_connectionStrings.contains("="))) {
    foreach ( $constring in $web_connectionStrings -split ",&," ) {
        $key,$val = $constring.split("=",2)
	    $connectionStrings.Add($key,$val)
    }
}

#Take the key value pairs from the hashtable and place them into an array to be supplied to the arm template. 
$tojsonconnectionStrings = @()
foreach ( $constring in $connectionStrings.Keys ) {
	$tojsonconnectionStrings += @{name=${constring};connectionString=$($connectionStrings.Item($constring));type="SQLAzure"}
}


# Ensure the Identity is one of 'None', 'SystemAssigned' and if not to 'None' 
$webIdentityValues = @{
					'None'           = $true
					'SystemAssigned' = $true }

if ( !$web_identity ) { $web_identity = "None" }
if ( !$webIdentityValues.ContainsKey($web_identity) ) { $web_identity = "None" }


if(!$web_webSocketsEnabled)
{
	$web_webSocketsEnabled = $false
}

if(!$web_clientAffinity)
 {
	 $web_clientAffinity = $true
 }

# coverting to boolean
try
 {
	$web_webSocketsEnabled = [System.Convert]::ToBoolean($web_webSocketsEnabled) 
 } catch [FormatException] {
	$web_webSocketsEnabled = $false 
 }

try
 {
	$web_clientAffinity = [System.Convert]::ToBoolean($web_clientAffinity)
 } catch [FormatException] {
	$web_clientAffinity = $true
 }

 if([string]::IsNullOrEmpty($asp_resourceGroup)){
	$asp_resourceGroup = $ResourceGroup
 }

 $hostPlan_Id = (Get-AzAppServicePlan -ResourceGroupName $asp_resourceGroup -Name $web_hostPlanName).Id

# Build deploymentParameters hashtable and check if allowedOrigins is an empty string. Do not pass as a deployment parameter value if empty
  New-Deployment "WebApp" @{ResourceGroupName       = $ResourceGroup
							TemplateFile            = "$PSScriptRoot/webapp.json"
							hostingPlanLinux        = $web_hostPlanLinux
							webSiteName             = $web_webSiteName
							webSocketsEnabled       = $web_webSocketsEnabled
							devLang                 = $web_devLang
							applicationSettings     = $tojsonapplicationSettings
							connectionStrings       = $tojsonconnectionStrings
							hostName                = $web_hostName
							webIdentity             = $web_identity
							clientAffinityEnabled   = $web_clientAffinity
							hostPlanId				= $hostPlan_Id }
