<#
 .SYNOPSIS
    Test a template based Azure Deployment

 .DESCRIPTION
    Deploys application service plan, and ensures that the parameters supplied match the parameters of the deployed Azure object.

 .PARAMETER ResourceGroup
	The resource group where the Azure object is deployed. 


 .PARAMETER asp_hostPlanName
	Name of the Application Service Plan


 .PARAMETER asp_skucode
	The Name of the SKU which uderpins the ASP i.e. S1,S2, B1 etc
	This is an optional parameter and a default will be set if not provided.

 .PARAMETER asp_defaultCapacity
	Default initial capacity of the ASP.

 .PARAMETER asp_maximumCapacity
	Maximum capacity of the ASP.

 .PARAMETER asp_minimumCapacity
	Minimum capacity of the ASP.

 .PARAMETER asp_alertEmails
	List of users that receive email alerts for the ASP.


 .PARAMETER asp_autoScaleOutCPU
    Amount of minimum average CPU utilisation percentage which needs to be achieved over a 10 minute period before the ASP scales out.
	This is an optional parameter and a default will be set if not provided.
	
 .PARAMETER asp_autoScaleInCPU
	Amount of maximum average CPU utilisation percentage which needs to be achieved over a 10 minute period before the ASP scales in.
	This is an optional parameter and a default will be set if not provided.


 PARAMETER asp_autoScaleMemory
    Enable or disabled the creation of Memory based Auto Scale rules for the ASP.
	This is an optional parameter and a default will be set if not provided.


 .PARAMETER asp_autoScaleOutMemory
    Amount of minimum average Memory utilisation percentage which needs to be achieved over a 10 minute period before the ASP scales out.
	This is an optional parameter and a default will be set if not provided.
	
 .PARAMETER asp_autoScaleInMemory
	Amount of maximum average Memory utilisation percentage which needs to be achieved over a 10 minute period before the ASP scales in.
	This is an optional parameter and a default will be set if not provided.
#>

#Include Shared Library
. $PSScriptRoot/DeploymentFunctions.ps1

# Configure default values for parameters which currently have no value passed by the deployment tool.
# Default Values.
$asp_autoScaleOutCPU_default = 90
$asp_autoScaleInCPU_default = 70
$asp_autoScaleOutMemory_default = 90
$asp_autoScaleInMemory_default = 60
$asp_skuCode_default = "P1v2"

# Configure default values.
if (!$asp_autoScaleOutCPU) {
	write-host "asp_autoScaleOutCPU not provided, setting default value to $asp_autoScaleOutCPU_default"
	$asp_autoScaleOutCPU = $asp_autoScaleOutCPU_default
}

if (!$asp_autoScaleInCPU) {
	write-host "asp_autoScaleInCPU not provided, setting default value to $asp_autoScaleInCPU_default"
	$asp_autoScaleInCPU = $asp_autoScaleInCPU_default
}

# If an input value is provided for both $asp_autoScaleOutMemory and $asp_autoScaleInMemory, enable memory autoscale
# If no input values are provided for either $asp_autoScaleOutMemory or $asp_autoScaleInMemory, disable memory autoscale and default both values to 0
if ($asp_autoScaleOutMemory -and $asp_autoScaleInMemory) {
	$asp_autoScaleMemory = "True"
} else {
	$asp_autoScaleMemory = "False"
	$asp_autoScaleOutMemory = $asp_autoScaleOutMemory_default
	$asp_autoScaleInMemory = $asp_autoScaleInMemory_default
}

if (!$asp_skuCode) {
	write-host "asp_skuCode not provided, setting default value to $asp_skuCode_default"
	$asp_skuCode = $asp_skuCode_default
}



$projectVariables = @{
	"Resource Group"        = $ResourceGroup
	"App Service Plan Name" = $asp_hostPlanName
	"SKU Code"              = $asp_skuCode
	"Default Capacity"      = $asp_defaultCapacity
	"Maximum Capacity"      = $asp_maximumCapacity
	"Minimum Capacity"      = $asp_minimumCapacity
	"AutoScaleOutCPU"   	= $asp_autoScaleOutCPU
	"AutoScaleInCPU"   	    = $asp_autoScaleInCPU
	"AutoScaleMemory"		= $asp_autoScaleMemory
	"AutoScaleOutMemory"	= $asp_autoScaleOutMemory
	"AutoScaleInMemory"		= $asp_autoScaleInMemory
	"Email Alerts"          = $asp_alertEmails
}

Write-Variables -component "Application Service Plan" -variables $projectVariables


New-Deployment "AppServicePlan" @{ResourceGroupName   = $ResourceGroup
	 							  TemplateFile 		  = "$PSScriptRoot/appserviceplan.json"
								  appServicePlanName  = $asp_hostPlanName
    							  skuCode 			  = $asp_skuCode
								  defaultCapacity 	  = $asp_defaultCapacity
								  maximumCapacity 	  = $asp_maximumCapacity
								  minimumCapacity 	  = $asp_minimumCapacity
								  AutoScaleOutCPU	  = $asp_autoScaleOutCPU
								  AutoScaleInCPU	  = $asp_autoScaleInCPU
								  AutoScaleMemory	  = $asp_autoScaleMemory
								  AutoScaleOutMemory  = $asp_autoScaleOutMemory
								  AutoScaleInMemory	  = $asp_autoScaleInMemory
								  alertEmails 		  = $asp_alertEmails}

