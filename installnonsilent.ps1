$path = "$PSScriptRoot\install\"
$softwares = import-csv "$PSScriptRoot\install\pkgs2.csv" -Delimiter "," -Header 'Installer','Switch' | Select-Object Installer,Switch

foreach($software in $softwares){
 
    $softexec = $software.Installer
    $softexec = $softexec.ToString()

    $pkgs = Get-ChildItem $path$softexec | Where-Object {$_.Name -eq $softexec}


    foreach($pkg in $pkgs){
   
        $ext = [System.IO.Path]::GetExtension($pkg)
        $ext = $ext.ToLower()

        $switch = $software.Switch
        $switch = $switch.Tostring()

        if($ext -eq ".msi"){
        
        Write-host "Installing $softexec non-silently, please wait...." -foregroundColor Yellow
        Start-Process "$path$softexec" -ArgumentList "$switch" -wait

        Write-host "Installation of $softexec completed" -foregroundColor Green
       
        }
        else{
       
        Write-host "Installing $softexec non-silently, please wait...." -foregroundColor Yellow
        Start-Process "$path$softexec" -ArgumentList "$switch" -wait -NoNewWindow

        Write-host "Installation of $softexec completed" -foregroundColor Green
       
        }     
   
   
    }
}