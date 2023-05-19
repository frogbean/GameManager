$VERSION = "6";

. ".\resources\volume.ps1"
. ".\resources\persistance.ps1"

#GAME RANGER AD BLOCK
function GRAdblock {	
	$gameRangers = Get-WmiObject Win32_Process -Filter "name = 'GameRanger.exe'"

	
	Foreach($gameRanger in $gameRangers) {
		
		$GRPath 	= $gameRanger.path;
		$GRCmdline 	= $gameRanger.commandLine -replace '"';
		
		if($GRCmdline.substring($GRCmdline.length -1) -eq " ") {
			$GRCmdline= $GRCmdline.substring(0,$GRCmdline.length-1)
		}
		
		if($GRPath -ne $GRCmdline) {
			Stop-Process -Id $gameRanger.handle -Force
			MLog("Killed an ad handler for GameRanger!")
		} 
	}

}
#END


$managePriority 	= [System.Convert]::ToBoolean((load "managePriority"))
$manageApps 		= [System.Convert]::ToBoolean((load "manageApps"))
$manageBinds 		= [System.Convert]::ToBoolean((load "manageBinds"))
$manageVolume 		= [System.Convert]::ToBoolean((load "manageVolume"))
$blockGameRangerAds = [System.Convert]::ToBoolean((load "manageAdds"))
$manageVolumeText 	= [string](load "manageVolumeText")

if(![bool]$manageVolumeText) {
	$manageVolumeText = "50";
}

	$firstPid = [int]0
	$TAMCount = [int]0

	
	Get-WmiObject Win32_process -filter "name = 'powershell.exe'" | forEach {
		if($_.CommandLine -Match "TAManager.ps1")  {
			if($TAMCount -eq 0) {
				$firstPid = $_.Handle
			}
			$TAMCount++;
		}
	}
	
	if($TAMCount -eq 2) {
		Write-Output "MANAGER DETECTED IN ANOTHER WINDOW!"
		Write-Host -NoNewLine 'Press any key to close the other instance...';
		$null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')
		Stop-Process -Id $firstPid
	}
	
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    
    # Set the size of your form
    $Form = New-Object System.Windows.Forms.Form
	$Form.width = 600
    $Form.height = 600
    $Form.Text = "TAManger Settings"

 
    # Set the font of the text to be used within the form
    $Font = New-Object System.Drawing.Font("Console",12)
    $Form.Font = $Font
 
    $MANAGE_PRIORITY = new-object System.Windows.Forms.checkbox
    $MANAGE_PRIORITY.Location = new-object System.Drawing.Size(30,50)
    $MANAGE_PRIORITY.Size = new-object System.Drawing.Size(250,50)
    $MANAGE_PRIORITY.Text = "Make the game process High Priority"
    $MANAGE_PRIORITY.Checked = $managePriority
    $Form.Controls.Add($MANAGE_PRIORITY) 
	
	$MANAGE_APPS = new-object System.Windows.Forms.checkbox
    $MANAGE_APPS.Location = new-object System.Drawing.Size(30,100)
    $MANAGE_APPS.Size = new-object System.Drawing.Size(250,50)
    $MANAGE_APPS.Text = "Stop and Restart apps in applications.txt"
    $MANAGE_APPS.Checked = $manageApps 
    $Form.Controls.Add($MANAGE_APPS) 
	
	$MANAGE_KEYBINDS = new-object System.Windows.Forms.checkbox
    $MANAGE_KEYBINDS.Location = new-object System.Drawing.Size(30,150)
    $MANAGE_KEYBINDS.Size = new-object System.Drawing.Size(250,50)
    $MANAGE_KEYBINDS.Text = "Use AutoHotKeys in rebinds Folder during game"
    $MANAGE_KEYBINDS.Checked = $manageBinds 
    $Form.Controls.Add($MANAGE_KEYBINDS) 
	
	$MANAGE_GR_ADBLOCK = new-object System.Windows.Forms.checkbox
    $MANAGE_GR_ADBLOCK.Location = new-object System.Drawing.Size(30,200)
    $MANAGE_GR_ADBLOCK.Size = new-object System.Drawing.Size(250,50)
    $MANAGE_GR_ADBLOCK.Text = "Block GameRanger Adverts"
    $MANAGE_GR_ADBLOCK.Checked = $blockGameRangerAds 
    $Form.Controls.Add($MANAGE_GR_ADBLOCK) 
	
	$MANAGE_VOLUME = new-object System.Windows.Forms.checkbox
    $MANAGE_VOLUME.Location = new-object System.Drawing.Size(30,250)
    $MANAGE_VOLUME.Size = new-object System.Drawing.Size(250,50)
    $MANAGE_VOLUME.Text = "Always set volume too when game is running"
    $MANAGE_VOLUME.Checked = $manageVolume 
    $Form.Controls.Add($MANAGE_VOLUME) 
	
	$MANAGE_VOLUME_INPUT = new-object System.Windows.Forms.TextBox
    $MANAGE_VOLUME_INPUT.Location = new-object System.Drawing.Size(30,300)
    $MANAGE_VOLUME_INPUT.Size = new-object System.Drawing.Size(250,260)
	$MANAGE_VOLUME_INPUT.Text = $manageVolumeText
    $Form.Controls.Add($MANAGE_VOLUME_INPUT) 
 
 
    # Add an OK button
    $OKButton = new-object System.Windows.Forms.Button
    $OKButton.Location = new-object System.Drawing.Size(30,350)
    $OKButton.Size = new-object System.Drawing.Size(100,40)
    $OKButton.Text = "OK"
    $OKButton.Add_Click({$Form.Close()})
    $form.Controls.Add($OKButton) 
    
    # Activate the form
    $Form.Add_Shown({$Form.Activate()}) 
    [void] $Form.ShowDialog() 
	
$managePriority 	= $MANAGE_PRIORITY.Checked;
$manageApps 		= $MANAGE_APPS.Checked;
$manageBinds 		= $MANAGE_KEYBINDS.Checked;
$manageVolume 		= $MANAGE_VOLUME.Checked
$manageVolumeText 	= $MANAGE_VOLUME_INPUT.Text;
$blockGameRangerAds = $MANAGE_GR_ADBLOCK.Checked;

save "managePriority" $managePriority 
save "manageApps" $manageApps 
save "manageBinds" $manageBinds 
save "manageVolume" $manageVolume 
save "manageVolumeText" $manageVolumeText 
save "manageAdds" $blockGameRangerAds


$goodGamesVolume = ([int]$MANAGE_VOLUME_INPUT.Text)/100;
$currentVolume = 0;

if($manageApps) {
	[string[]]$apps = Get-Content -Path 'applications.txt'
} else {
	$apps = @();
}

[string[]]$games = Get-Content -Path 'games.txt'
$gameStr = $games -join ", ";
$appsStr = $apps -join ", ";

function header {
	cls
	Write-Output "";
	Write-Output "	Game Manager v$VERSION";
	Write-Output "";
	Write-Output "		high priority enabled: 	$managePriority"
	Write-Output "		app kill enabled: 	$manageApps ($appsStr)"
	Write-Output "		GR Adblock enabled: 	$blockGameRangerAds"
	Write-Output "		use keybinds: 		$manageBinds"
	Write-Output "		manage volume: 		$manageVolume ($manageVolumeText)"
	Write-Output "		Games:			$gameStr";
	Write-Output "";
	Write-Output "";
	$arr = $global:consoleBuffer[0..15]
	[array]::Reverse($arr);
	Write-Output $arr;
};

$global:consoleBuffer = @();
function console {
	Param (
		[string]$message,
		[int]$max
	)
	$global:consoleBuffer = ,$message + $global:consoleBuffer
	
}

function MLog{
	Param (
		$message
	)
	$date = (Get-Date -Format "HH:mm:ss");
	$ident = "TAM $VERSION"
	$out= "	[$ident $date]	$message"
	console($out);
	
	if (!(Test-Path "log.txt")) {
	   New-Item -name log.txt -type "file" -value ""
	}
	Add-Content -Path log.txt -Value $out
	header
}



function getProc {
	Param (
		$procName
		)
	return Get-WmiObject Win32_process -filter "name = '$procName.exe'";
};

function tap {
		param (
		$gameName
		)
	try {
		return (get-process -Name $gameName).priorityclass;
		} catch {
	}
	
};

function StartAHK {
	
	param (
        $AHKPath
    )

	$close = '"';
	Start-Process -FilePath "resources\AHK\AutoHotkeyU64.exe" -ArgumentList "$close$AHKPath$close";
	
}




function AutoHotKeyManager  {
	param (
		$gameFolder
	)
	
	if(Test-Path "rebinds\$gameFolder") {
		Get-ChildItem rebinds\$gameFolder\* -Filter *.ahk | % {
			$tempName = $_.Name;
			MLog("starting script: $tempName"); 
			StartAHK($_)
		}
	}
}

$global:appPaths = @();

function appHandler {
	param (
		$appName
		)
		
		
	if((getProc($appName))) { 
			
		if(((getProc($appName)).Path[1].length) -eq 1) {
			$appPath = ((getProc($appName)).Path);
		} else {
			$appPath= ((getProc($appName)).Path[1]);
		}
		
		MLog("closing: $appName")
		$global:appPaths += $appPath
		(Invoke-Expression "taskkill /IM $appName.exe > resources\null 2>&1") | Out-Null
		(Invoke-Expression "taskkill /F /IM $appName.exe > resources\null 2>&1") | Out-Null
	}
}

$lock_mode = 1;
$activeGame = "";

header

While(1)
{
	
	if($blockGameRangerAds) {
		GRAdblock
	}
	
	if($lock_mode) {

		forEach($game in $games) {
			if( (getProc($game)) -and $lock_mode) {
				$lock_mode = 0;
				$activeGame = $game;
				MLog("$activeGame detected");
				
				if($manageVolume) {
					$currentVolume = [audio]::Volume;
					[audio]::Volume = $goodGamesVolume;
					
					[math]::Round(([float]$goodGamesVolume)*100)
					
					[int]$goodGamesVolumeOut = [math]::Round(([float]$goodGamesVolume)*100)
					[int]$currentVolumeOut = [math]::Round(([float]$currentVolume)*100)
					
					MLog("Changing volume from $currentVolumeOut% too $goodGamesVolumeOut%");
				}
				
				if($manageBinds) {
					AutoHotKeyManager($activeGame);
				}
				
				if( ((tap($activeGame)) -ne 'High') -and ($managePriority)) {
					
					MLog("Setting high prorirty on $game.exe!");
					((getProc($activeGame)).SetPriority(128)) | Out-Null;
				}
				
				ForEach ($app in $apps) {
				appHandler($app);
				}
				
			}
		}
	} else {
			
		if(!(getProc($activeGame)) -and ($lock_mode -eq 0)) {

			$date = (Get-Date -Format "HH:mm:ss");
			MLog("$activeGame.exe closed, Tidying Up!");
			
			
			
			if($manageVolume) {
				[int]$goodGamesVolumeOut = [math]::Round(([float]$goodGamesVolume)*100)
				[int]$currentVolumeOut = [math]::Round(([float]$currentVolume)*100)
				MLog("Changing volume from $goodGamesVolumeOut% too $currentVolumeOut%");
				[audio]::Volume = $currentVolume;
			}
			
			if($global:appPaths.count -ne 0) {
				
				MLog("Restarting apps");
				ForEach ($app in $global:appPaths) {
					Start-Process "$app" | Out-Null;
				}
				$global:appPaths = @()
				
			}
			
			$ahku = Get-WmiObject Win32_process -filter 'name = "AutoHotKeyU64.exe"';
			if($ahku) {
				MLog("closing autohotkey's");
				(taskkill /F /IM AutoHotKeyU64.exe) | Out-Null;
			}
			header;
			$lock_mode = 1;
		}	
	}
	Start-Sleep -s 1
}