#Instance Configuration
$config = "D:\config\arma\training1.json"
#
$configJson = Get-Content -Raw -Path $config | ConvertFrom-Json
$instanceId = $configJson.server.env.SERVER_ID
$serverName = $configJson.server.env.SERVER_NAME
$modListJson = $configJson.mods
$serverModListJson = $configJson.servermods
$localModListJson = $configJson.localmods
$configDir = $configJson.server.env.ARMA_CONFIG_PATH
$steamCMDdir = $configJson.server.env.STEAM_BASE_PATH
$installDirWorkshop = $configJson.server.env.STEAM_WORKSHOP_PATH
$installDir = $configJson.server.env.ARMA_BASE_PATH
$installDirArmadirectory = $installDir
$localModDir = $configJson.server.env.LOCAL_MOD_PATH
$steamUser = $configJson.server.env.STEAM_USERNAME
$steamPass = $configJson.server.env.STEAM_PASSWORD
#
$configDir = "$configDir\$serverName"

#For purposes of updating no need to have seperate arrays for mods.
$modListJson = $modListJson += $serverModListJson

Write-Output "Update has started: $(Get-Date)"

#Stop Firedaemon Service
#net stop $instanceName

#login to steamcmd using env variables
$argumentListArray = "+login $steamUser $steamPass +force_install_dir "+$installDir+" "
#download each item in steamcmd using the app id in the mod list array
foreach($item in $modListJson) 
{
	$id = $item.app
	$argumentListArray += "+workshop_download_item 107410 $id "
}   
#update and validate arma 3 base installation
$argumentListArray += "+force_install_dir $installDirArmadirectory +app_update 233780 validate +quit"
Write-Output $argumentListArray

Start-Process -FilePath $steamCMDdir -ArgumentList $argumentListArray -NoNewWindow -Wait
Write-Output Start-Process -FilePath $steamCMDdir -ArgumentList $argumentListArray -NoNewWindow -Wait
#copying keys
foreach($item in $modListJson) 
{
   $id = $item.app
   $name = $item.name

   copy-item $installDirWorkshop\$id\keys\*.bikey $installDirArmadirectory\keys\ -force -recurse
   Write-Output copy-item $installDirWorkshop\$id\keys\*.bikey $installDirArmadirectory\keys\ -force -recurse
   copy-item $installDirWorkshop\$id\key\*.bikey $installDirArmadirectory\keys\ -force -recurse
   Write-Output copy-item $installDirWorkshop\$id\key\*.bikey $installDirArmadirectory\keys\ -force -recurse

   New-Item -Path $installDirArmadirectory\$name -ItemType SymbolicLink -Value $installDirWorkshop\$id

}

#local mod retreival
foreach($item in $localModListJson)
{
   $name = $item.name
   $path = $localModDir

   copy-item $path\$name $installDirArmadirectory\ -force -recurse
   Write-Output copy-item $path\$name $installDirArmadirectory -force -recurse
   copy-item $installDirArmadirectory\$name\keys\*.bikey $installDirArmadirectory\keys\ -force -recurse
   Write-Output copy-item $installDirArmadirectory\$name\keys\*.bikey $installDirArmadirectory\keys\ -force -recurse
   copy-item $installDirArmadirectory\$name\key\*.bikey $installDirArmadirectory\key\ -force -recurse
   Write-Output copy-item $installDirArmadirectory\$name\key\*.bikey $installDirArmadirectory\key\ -force -recurse
}

#Removing logs after update
Remove-Item $configDir+\training1\*.rpt 
Remove-Item $configDir+\training1\*.log 
Write-Output Remove-Item $configDir+\training1\*.rpt 
Write-Output Remove-Item $configDir+\training1\*.log 
Remove-Item $configDir+\training2\*.rpt 
Remove-Item $configDir+\training2\*.log
Write-Output Remove-Item $configDir+\training2\*.rpt 
Write-Output Remove-Item $configDir+\training2\*.log 
Remove-Item $configDir+\training3\*.rpt 
Remove-Item $configDir+\training3\*.log 
Write-Output Remove-Item $configDir+\training3\*.rpt 
Write-Output Remove-Item $configDir+\training3\*.log 
Remove-Item $configDir+\training4\*.rpt 
Remove-Item $configDir+\training4\*.log
Write-Output Remove-Item $configDir+\training4\*.rpt 
Write-Output Remove-Item $configDir+\training4\*.log

Write-Output "Update has finished: $(Get-Date) for $serverName"

#Start Firedaemon Service
#net start $instanceName