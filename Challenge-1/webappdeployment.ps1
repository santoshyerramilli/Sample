<#
	.DESCRIPTION
		This populates a number of Powershell variables to allow the deployment of a webapp.
		Assumes that the Resource Group and App Service Plan are already created.
#>

$ResourceGroup      = "dev-test-rg"
$web_hostPlanName   = "dev-test-asp"
$web_hostPlanLinux  = $false
$web_websiteName    = "dev-test-wepapp"
$web_devLang        = "net"
$web_allowedOrigins = "*"
$web_appSettings    = "APPINSIGHTS_INSTRUMENTATIONKEY=******;WEBSITE_WEBDEPLOY_USE_SCM=false"
$web_connectionStrings = "connectionstring=******"
$asp_resourceGroup  = ""
$web_ipRestrictions	= ""
$asp_resourceGroup  = "dev-test-rg"



Try {
	./webapp.ps1

} Catch {
	$Exception = $_
	Write-Error $Exception

} 
