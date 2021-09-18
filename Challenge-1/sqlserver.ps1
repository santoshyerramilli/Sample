<#
 .SYNOPSIS
    Deploy and Test a template based Azure Deployment

 .DESCRIPTION
    Deploys SQL Server, and ensures that the parameters supplied match the parameters of the deployed Azure object.
	Will deploy with or without an Elastic Pool.

 .PARAMETER ResourceGroup
	The resource group where the Azure object is deployed. 
	
 .PARAMETER sql_serverName
	Name of the SQL Serer to deploy.
	
 .PARAMETER sql_administratorLogin
	Username for the SQL Server administrator account.
	
 .PARAMETER sql_administratorLoginPassword
	Password for the SQL Server administrator account.
	
 .PARAMETER sql_adminEmail
	Email for auditing and alerts.
	
 .PARAMETER sql_auditStorageAccountName
	Name of the general storage account used for Auditing.
	
 .PARAMETER sql_useElastic
	Whether an elastic pool is included in the deployment. Accepted Values "True" or "False".
	
 .PARAMETER sql_elasticPoolName
	Name for the SQL Elastic Pool.

#>

#Include Shared Libraries
. $PSScriptRoot/DeploymentFunctions.ps1

# Uses secure string for password contents so they don't appear in any logs.
$sql_passwordSecure = $sql_administratorLoginPassword | ConvertTo-SecureString -AsPlainText -Force

$projectVariables = [ordered]@{"Resource Group"       = $ResourceGroup
							   "SQL Server Name"      = $sql_serverName
							   "Admin Username"       = $sql_administratorLogin
							   "Admin Password"       = $sql_passwordSecure
							   "Admin Email"          = $sql_adminEmail
							   "Storage Account Name" = $sql_auditStorageAccountName
							   "Elastic Pool"         = $sql_useElastic
							   "Elastic Pool Name"    = $sql_elasticPoolName
                               "ElasticPoolDTU"       = $sql_elasticPoolDTU}

Write-Variables -component "SQL Server" -variables $projectVariables


# Deploy the SQL Server.
New-Deployment "SQLServer" @{ResourceGroupName       		= $ResourceGroup
							  TemplateFile          		= "sqlserver.json"
							  projectCode            		= $sql_projectCode
							  serverName             		= $sql_serverName
							  administratorLogin			= $sql_administratorLogin	   
							  administratorLoginPassword    = $sql_passwordSecure
							  alertEmails		 			= $sql_adminEmail
							  storageAccountName      		= $sql_auditStorageAccountName
							  elastic	          			= $sql_useElastic
							  elasticPoolName          		= $sql_elasticPoolName
	                          elasticPoolDTU                = $sql_elasticPoolDTU}

