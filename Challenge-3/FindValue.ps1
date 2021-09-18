$count=0
$object = Read-Host "Pass object in a json file format"
$key = Read-Host "Pass a key"
$json=(Get-Content "$object" -Raw| ConvertFrom-Json)| ForEach-Object {
    if($key -eq $_.name) {
      Write-host "For $($_.Name) value is : $($_.Value)" 
      $count++}


 }
       if($count -eq 0) {
      write-error "wrong key provided" }


