
$ResourceGroup                  = "dev-test-rg"
$sql_serverName                 = "dev-test-sqlserver"
$sql_administratorLogin         = "dwh-dk-admin"
$sql_administratorLoginPassword = "*****"
$sql_adminEmail                 = "*****"
$sql_auditStorageAccountName    = "storagertest"
$sql_useElastic                 = "False"
$sql_elasticPoolName            = "nopool"
$sql_elasticPoolDTU             = 100



Try {
	./sqlserver.ps1
 } Catch {
	$Exception = $_
	Write-Error $Exception
}


