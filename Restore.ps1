$path = "$PSScriptRoot\backup\"
$locations = import-csv "$PSScriptRoot\backup\local.csv" -Delimiter "," -Header 'Local','Backup','Display' | Select-Object Local,Backup,display

foreach($location in $locations){
 
   $source = $location.Local
    $source = [System.Environment]::ExpandEnvironmentVariables(($source))

    $destination = $location.Backup
    $destination = [System.Environment]::ExpandEnvironmentVariables(($destination))
   
    $Name = $location.Display
    $Name = $name.tostring()

    Write-host "Restoring $Name, please wait...." -foregroundColor Yellow
    robocopy "$path$source" "$destination" /copyall /S /E
  
   
}