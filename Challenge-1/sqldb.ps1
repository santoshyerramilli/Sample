<#
 .SYNOPSIS
    Deploy and Test a template based Azure Deployment

 .DESCRIPTION
    Deploys  SQL database, and ensures that the parameters supplied match the parameters of the deployed Azure object.
	Will deploy with or without an Elastic Pool.

 .PARAMETER ResourceGroup
	The resource group where the Azure object is deployed. 

 .PARAMETER sql_serverName
	Name of the SQL Server to deploy to.
	
 .PARAMETER sql_databaseName
	Name of the SQL Database to deploy.

 .PARAMETER sql_collation
	Name of the SQL Database collation. Default value - "SQL_Latin1_General_CP1_CI_AS". For case sensitive - "SQL_Latin1_General_CP1_CS_AS".

 .PARAMETER sql_edition
	Name Of The edition Of The SQL Database

 .PARAMETER sql_requestedServiceObjectiveName  
	Name of the Service Objective Name.

 .PARAMETER sql_useElastic
	Whether an elastic pool is included in the deployment. Accepted Values "True" or "False".
	
 .PARAMETER sql_elasticPoolName
	Name for the SQL Elastic Pool.

#>

#Include Shared Libraries
. $PSScriptRoot/DeploymentFunctions.ps1

if(!$sql_minCapacity) {
	$sql_minCapacity = ""
}

if(!$sql_maxCapacity) {
	$sql_maxCapacity = 0
}

if(!$sql_autoPauseDelay) {
	$sql_autoPauseDelay = -1
}

if(!$sql_maxSizeBytes){
	if ($sql_edition -eq "Hyperscale") {
		$sql_maxSizeBytes = -1
	} else {
	$sql_maxSizeBytes = 268435456000
}
}


$projectVariables = [ordered]@{"Resource Group"              = $ResourceGroup
							   "SQL Database Name"           = $sql_databaseName
							   "SQL Server Name"             = $sql_serverName
							   "SQL Database collation"      = $sql_collation
							   "elastic Pool Name"           = $sql_elasticPoolName
                               "Service Objective Name"      = $sql_requestedServiceObjectiveName  	
                               "Min Capacity"                = $sql_minCapacity
							   "Max Capacity"                = $sql_maxCapacity
							   "Max Size Bytes"              = $sql_maxSizeBytes}


Write-DeploymentParameterHeader -component "SQL Database" -variables $projectVariables


# Deploy the SQL Database.
New-Deployment "SQLDatabase" @{ResourceGroupName       		    = $ResourceGroup
							  TemplateFile          		    = "$PSScriptRoot/sqldb.json"
							  databaseName             		    = $sql_databaseName
							  serverName             		    = $sql_serverName
							  collation							= $sql_collation
							  requestedServiceObjectiveName     = $sql_requestedServiceObjectiveName  	
                              edition                           = $sql_edition  		
							  elasticPoolName          		    = $sql_elasticPoolName
							  minCapacity                       = $sql_minCapacity
							  maxCapacity                       = $sql_maxCapacity
							  maxSizeBytes                      = $sql_maxSizeBytes}

