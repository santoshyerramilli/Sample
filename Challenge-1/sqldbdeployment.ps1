$ResourceGroup                     = "dev-test-rg"
$sql_serverName                    = "dev-test-sqlserver"
$sql_databaseName                  = "dev-test-sqldb"
$sql_edition                       = "Standard"
$sql_requestedServiceObjectiveName = "S0" 
$sql_elasticPoolName               = ""


Try {
	./sqldb.ps1

} Catch {
	$Exception = $_
	Write-Error $Exception

} 



