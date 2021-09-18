function Write-Variables {
	
	param([string]$component,
		  $variables)

	Write-Host "=================================================="
	Write-Host "$component - Deployment & Validation"
	Write-Host "=================================================="
	$variables.GetEnumerator() | Sort-Object -Property Name | Format-Table -AutoSize -Wrap | Out-String -Width 200 
    Write-Host "."

}


function New-Deployment {

	param($component,
		  $variables,
		  [Parameter(Mandatory=$false)][bool]$failOnDeploymentError = $false)


	$randomDeployNo = Get-Random -Minimum 1 -Maximum 10000
	$deployCommand = "New-AzResourceGroupDeployment -Name $component-$randomDeployNo `n                                   -Verbose `n"
	
	foreach ($item in $variables.keys) {
		$deployCommand += "                                   -" + $item + " " + $variables[$item] + "`n"
	}
	
	Write-Host $deployCommand
	Write-Verbose (Get-Content $variables["TemplateFile"] | Out-String)

	New-AzResourceGroupDeployment -Name $component-$randomDeployNo -Verbose @variables

	# Instances of tag validation failed where resources were retrieved from Azure before fully deployed. Added sleep to counter this.
	Start-Sleep -seconds 5
	
	#Fail the deployment process if there is a deployment failure and $failOnDeploymentError is set to $true.
	if ($failOnDeploymentError) {
		$deployment = Get-AzResourceGroupDeployment -ResourceGroupName $variables["ResourceGroupName"] -Name $component-$randomDeployNo
		if ($deployment.ProvisioningState -eq "Failed") {
			Write-DeploymentFailed "Deployment Name $component-$randomDeployNo is in a failed state - Aborting deployment process"
		}
	}

	return "$component-$randomDeployNo"
}