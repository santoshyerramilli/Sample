
$ResourceGroup       	= "dev-test-rg"
$asp_hostPlanName    	= "dev-test-asp"
$asp_skuCode         	= "B1"
$asp_defaultCapacity 	= "1"
$asp_maximumCapacity 	= "2"
$asp_minimumCapacity 	= "1"
$asp_autoScaleoutCPU 	= "70"
$asp_autoScaleInCPU  	= "60"
$asp_autoScaleOutMemory = "75"
$asp_autoScaleInMemory  = "45"
$asp_alertEmails		= "abc@mail.com"


Try {
	./appserviceplan.ps1
 } Catch {
	$Exception = $_
	Write-Error $Exception
}