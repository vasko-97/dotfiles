oh-my-posh init pwsh | Invoke-Expression

$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"

if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}


function EnableVimMode () {
# enable Vim on the shell and as editor
	$OnViModeChange = [scriptblock]{
		if ($args[0] -eq 'Command') {
# Set the cursor to a blinking block.
			Write-Host -NoNewLine "`e[2 q"
		}
		else {
# Set the cursor to a blinking line.
			Write-Host -NoNewLine "`e[5 q"
		}
	}

		Set-PsReadLineOption -EditMode Vi
		Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $OnViModeChange

# Make Ctrl+[ exit insert mode
		Set-PSReadLineKeyHandler -Chord 'Ctrl+Oem4' -Function ViCommandMode

# Autocompletion for arrow keys
		Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
		Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
		Set-PSReadlineKeyHandler -Chord 'Ctrl+p' -Function HistorySearchBackward
		Set-PSReadlineKeyHandler -Chord 'Ctrl+n' -Function HistorySearchForward

# This is needed to autocomplete the transparent suggestion shown as you type a command
		Set-PSReadlineKeyHandler -Chord 'Ctrl+f' -Function ViForwardChar

# make some basic Vim keybinds work as expected
		Set-PSReadlineKeyHandler -Chord 'Ctrl+w' -Function BackwardDeleteWord -ViMode Insert
		Set-PSReadlineKeyHandler -Chord 'Ctrl+h' -Function BackwardDeleteChar -ViMode Insert
}

# disable vim mode completely to try to get used to readline bindings... pwsh vim mode is limited and doesn't work at all in Jetbrains terminal anyway
# $shouldEnableVimMode = $env:TERMINAL_EMULATOR -notlike "*JetBrains*"
$shouldEnableVimMode = $false
if ($shouldEnableVimMode) {
	EnableVimMode
}
else {
	Set-PSReadLineOption -EditMode Emacs
}

$InformationPreference = "Continue"
$ErrorActionPreference = "Stop";

# refresh komorebi applications.json apps behaving badly file
komorebic fetch-asc

Import-Module -Name Terminal-Icons
Import-Module posh-git

Invoke-Expression (& { (zoxide init powershell | Out-String) })

########################################################################################## fzf JetBrains project opener ##################################################################################################################################

$Global:JB_RiderExe = "C:\Users\VasilijeSpaic\AppData\Local\Programs\Rider\bin\rider64.exe"
$Global:JB_DataGripExe = "C:\Users\VasilijeSpaic\AppData\Local\Programs\DataGrip\bin\datagrip64.exe"

$Global:JB_RiderProjectsRoot = "C:\DevGit\"
$Global:JB_DataGripProjectsDir = "C:\DevGit\DevTools\DataGripProjects"

$Global:JB_CustomProjects = @(
    @{
        Name = "dotfiles"
        Path = "C:\DevGit\dotfiles"
        Ide  = "rider"
    }
)

function Open-JBProject {

    $items = @()

    # Build Everything query
    if ($Global:JB_RiderProjectsRoot) {
        $query = "*.sln path:$Global:JB_RiderProjectsRoot"
    }
    else {
        $query = "*.sln"
    }

    $slnFiles = Invoke-Expression "es.exe $query"

    # Add Rider projects
    foreach ($file in $slnFiles) {
        $items += [PSCustomObject]@{
            Display = "Rider | $(Split-Path $file -Leaf) | $(Split-Path $file -Parent)"
            Path    = $file
            Ide     = $Global:JB_RiderExe
        }
    }

    # Add DataGrip projects
    if (Test-Path $Global:JB_DataGripProjectsDir) {
        $dataGripDirs = Get-ChildItem -Path $Global:JB_DataGripProjectsDir -Directory
        foreach ($dir in $dataGripDirs) {
            $items += [PSCustomObject]@{
                Display = "DataGrip | $($dir.Name) | $($dir.FullName)"
                Path    = $dir.FullName
                Ide     = $Global:JB_DataGripExe
            }
        }
    }

    # Add custom IDE entries
    foreach ($proj in $Global:JB_CustomProjects) {
        $items += [PSCustomObject]@{
            Display = "Custom | $($proj.Name) | $($proj.Path)"
            Path    = $proj.Path
            Ide     = $proj.Ide
        }
    }

    if (-not $items) {
        Write-Host "No projects found."
        return
    }

    $selection = $items |
        Select-Object -ExpandProperty Display |
        fzf --height=40% --layout=reverse --border --prompt="Projects > "

    if (-not $selection) { return }

    $chosen = $items | Where-Object { $_.Display -eq $selection }

    if ($chosen) {
        Start-Process $chosen.Ide "`"$($chosen.Path)`"" -WindowStyle Normal
    }
}

Set-Alias jb Open-JBProject
##################################################################################################################################################################################################################################################

# - add logging to all this
# - extract dev folder to env variable
function SetUpSaturnRepoToUseLocalNugetLibraries {
  param(
      $RepoName,
      $LibFilter
    )

  if(-not $RepoName){
    Write-Output "LibFilter - starting string of the group of libs to set up to use local nuget packages, eg. LibFilter=Universe.MessageBus"
    Write-Output "RepoName - Saturn repo which will be updated to use the local nuget packages, eg. Metadata."
    Write-Output "Example usage:"
    Write-Output "SetUpSaturnRepoToUseLocalNugetLibraries -RepoName Metadata -LibFilter 'Universe.MessageBus'"
    return;
  }

  PackLocalNugetsToBeUsedInSaturnRepo -RepoName $RepoName -CsprojFilter $LibFilter;
  UpdateSaturnRepoToUseLocalPackages -RepoName $RepoName -LibStartsWithFilter $LibFilter;
  Get-Childitem "C:\DevGit\Saturn\$RepoName" -Recurse -Filter Dockerfile | % {PrepareDockerfile -PathToDockerfile $_.FullName}
  PrepareNugetConfig -RepoName $RepoName
}

function PackLocalNugetsToBeUsedInSaturnRepo {
  param(
      $CsprojFilter,
      $RepoName
    )
  Get-Childitem C:\DevGit -Recurse -Filter "$CsprojFilter*csproj" -Exclude '*test*' -ErrorAction Continue | ForEach-Object {

    # output to localnugets to be used in docker buids
    dotnet pack $_.FullName --version-suffix local -o "C:\DevGit\Saturn\$RepoName\localnugets"

    # also output to vaskolocalfeed so it can bbe used in Rider builds
    Copy-Item "C:\DevGit\Saturn\$RepoName\localnugets\*" "C:\vaskolocalfeed\"
    #dotnet pack $_.FullName --version-suffix local -o "C:\vaskolocalfeed"
  }
}

function UpdateSaturnRepoToUseLocalPackages {

  param(
      $RepoName,
      $LibStartsWithFilter
    )

  Get-Childitem "C:\DevGit\Saturn\$RepoName" -Recurse -Include "*csproj", "Directory.Packages.props" -Exclude '*test*' | % {UpdateFileToUseLocalNuget -FilePath $_.FullName -LibStartsWithFilter $LibStartsWithFilter}
}

function UpdateFileToUseLocalNuget {

  param (
        $FilePath,
        $LibStartsWithFilter
    )

  Write-Output "Updating $FilePath"

  $fileContent = Get-Content -Path $FilePath

  $containsLib = $false;
  foreach($line in $fileContent){
    if($line.Contains($LibStartsWithFilter) -and $line.Contains("Version")){ # ignore files that either don't contain the lib at all, or that contain it but they derive the version from Directory.Packages.props
      $containsLib = $true;
      break;
    }
  }

  if(-not $containsLib){
    Write-Output "not updating $FilePath as it does not contain the specified libraries"
    return;
  }

  # Escape the content of the variable to handle any regex special characters
  $escapedLibStartsWithFilter = [regex]::Escape($LibStartsWithFilter)

  # Define the regular expression pattern using the escaped variable
  $pattern = "(${escapedLibStartsWithFilter}[^""]*)"" Version=""[^""]+"""

  # Define the replacement string
  $replacement = '${1}" Version="1.0.0-local"'


  # Perform the replacement
  $updatedContent = $fileContent -replace $pattern, $replacement

  Set-Content -Path $FilePath -Value $updatedContent
}

# todo This should also be done for $RepoName rather than $PathToDockerfile
# todo we also need to add the package source mapping *1.0.0-local to the repo's nuget config here.
function PrepareDockerfile {
  param(
    $PathToDockerfile
    )

  $content = Get-Content $PathToDockerfile

  $alreadyPrepared = $false;
  foreach($line in $content){
    if($line.Contains("localnugets")){
      $alreadyPrepared = $true;
      break;
    }
  }

  if($alreadyPrepared){
    return;
  }

  $nugetRestoreLineIdentifier = 'RUN dotnet restore';

  $linesToInsert = @(
      'COPY ["localnugets/*", "./localnugets/"]',
      'RUN dotnet nuget add source "/repo/localnugets" -n "vaskolocalfeed"'
  )

  $newContent = @()

  foreach ($line in $content) {
      if ($line.StartsWith($nugetRestoreLineIdentifier)) {
          # Insert the lines before the current line
          foreach ($insertLine in $linesToInsert) {
              $newContent += $insertLine
          }
      }
      # Add the current line to the new content
      $newContent += $line
  }

  # Write the new content back to the file
  $newContent | Set-Content $PathToDockerfile
}

function PrepareNugetConfig {
  param(
    $RepoName
    )

  $newNugetConfig=
  '<?xml version="1.0" encoding="utf-8"?>
<configuration>
  <packageSources>
    <add key="nuget.org" value="https://api.nuget.org/v3/index.json" protocolVersion="3" />
    <add key="scopemarkets" value="https://nuget.pkg.github.com/ScopeMarkets/index.json" />
  </packageSources>
    <packageSourceMapping>
      <packageSource key="vaskolocalfeed">
            <package pattern="Universe.*" />
            <package pattern="Sm.*" />
        </packageSource>
      <packageSource key="scopemarkets">
            <package pattern="Universe.*" />
            <package pattern="Sm.*" />
        </packageSource>
        <packageSource key="nuget.org">
            <package pattern="*" />
        </packageSource>
    </packageSourceMapping>
</configuration>'

  Set-Content "C:\DevGit\Saturn\$RepoName\nuget.config" $newNugetConfig;
}

function DockerForceRemoveImages{
  param(
    $NameFilter
    )

  # Stop and remove all running containers using images matching 'my_image_name'
  docker ps --filter "ancestor=$NameFilter" --format "{{.ID}}" | ForEach-Object { docker stop $_; docker rm $_ }

# Remove all images matching 'my_image_name'
  docker images $NameFilter --format "{{.ID}}" | ForEach-Object { docker rmi -f $_ }
}


function DockerRemoveContainersAndImages {
  param(
    $NameMatch)
  
  docker container rm $(docker container ls --filter "name=$NameMatch" -q) --force;
  docker image rm $(docker images *$NameMatch* -q)
}

function Invoke-CodeSearch {
  param($SearchTerm, $Repo)
  if($Repo){
    $url="https://github.com/search?q=org%3AScopeMarkets+$SearchTerm+repo%3AScopeMarkets%2F$Repo+&type=code"
  }
  else{
    $url = "https://github.com/search?q=org%3AScopeMarkets+$SearchTerm&type=code"
  }
  Start-Process "msedge.exe" -ArgumentList $url
}
Set-Alias cs Invoke-CodeSearch

function Invoke-WikiSearch {
  param($SearchTerm)

  Start-Process "msedge.exe" -ArgumentList "https://scopemarkets.atlassian.net/wiki/search?text=$SearchTerm"
}
Set-Alias wiki Invoke-WikiSearch

function aws-test {
	$env:AWS_PROFILE = "test"
		aws sso login --profile test
}

function aws-prod {
	$env:AWS_PROFILE = "prod"
		aws sso login --profile prod
}


function Invoke-ClearLocalNugets {
    param (
        [Parameter(Mandatory = $true)]
        [string]$Filter
    )

    $localNugetPaths = @('C:\Users\vasilije.spaicis\AppData\Local\NuGet\v3-cache', 'C:\Users\vasilije.spaicis\.nuget\packages', 'C:\Users\vasilije.spaicis\AppData\Local\Temp\NuGetScratch', 'C:\Users\vasilije.spaicis\AppData\Local\NuGet\plugins-cache');

    foreach($packagePath in $localNugetPaths) {

      if (-not (Test-Path $packagePath)) {
          Write-Host "Could not find a folder at $packagePath"
          return
      }

      # Find all directories that match the provided string
      $matchingPackages = Get-ChildItem -Path $packagePath -Directory -Recurse |
                          Where-Object { $_.Name -like "*$Filter*" }

      if ($matchingPackages.Count -eq 0) {
          Write-Host "No packages found matching '$Filter'."
          return
      }

      # Loop through and delete each matching package
      foreach ($package in $matchingPackages) {
          Write-Host "Deleting package: $($package.FullName)"
          Remove-Item -Recurse -Force -Path $package.FullName
      }

      Write-Host "Finished clearing NuGet packages matching '$Filter' from location $packagePath."
    }
    
}


if(-not $shouldEnableVimMode){
	return
}
######################################################################
# Copied from Github to get Vim text objects working in PSReadLine ###
######################################################################
function VIDecrement( $key , $arg ){
	[int]$numericArg = 0
	[Microsoft.PowerShell.PSConsoleReadLine]::TryGetArgAsInt($arg,
		  [ref]$numericArg, 1)
	$Line = $Null
	$Cursor = $Null
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$Line,`
		[ref]$Cursor)
	$OpeningQuote=' '
	$ClosingQuote=' '
	$EndChar=$Line.indexOf($ClosingQuote, $Cursor)
	$StartChar=$Line.LastIndexOf($OpeningQuote, $Cursor) + 1
	[int]$nextVal = $Line.Substring($StartChar, $EndChar - $StartChar)
	$nextVal -= $numericArg

	[Microsoft.PowerShell.PSConsoleReadLine]::Replace($StartChar,`
				$EndChar - $StartChar, $nextVal.toString() )
	[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($EndChar - 1)
}

function VIIncrement( $key , $arg ){
	[int]$numericArg = 1
	[Microsoft.PowerShell.PSConsoleReadLine]::TryGetArgAsInt($arg,
		  [ref]$numericArg, 1)
	$Line = $Null
	$Cursor = $Null
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$Line,`
		[ref]$Cursor)
	$OpeningQuote=' '
	$ClosingQuote=' '
	$EndChar=$Line.indexOf($ClosingQuote, $Cursor)
	$StartChar=$Line.LastIndexOf($OpeningQuote, $Cursor) + 1
	[int]$nextVal = $Line.Substring($StartChar, $EndChar - $StartChar)
	$nextVal += $numericArg

	[Microsoft.PowerShell.PSConsoleReadLine]::Replace($StartChar,`
				$EndChar - $StartChar, $nextVal.toString() )
	[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($EndChar - 1)
}

function VIChangeInnerBlock(){
	VIDeleteInnerBlock
	[Microsoft.PowerShell.PSConsoleReadLine]::ViInsertMode()
}

function VIDeleteInnerBlock(){
	$Caps = "$[({})]-._ '```"" + ([char]'A'..[char]'Z' |% { [char]$_ }) -join '' 
	$quotes = New-Object system.collections.hashtable
	$quotes["'"] = @("'","'")
	$quotes['"'] = @('"','"')
	$quotes["("] = @('(',')')
	$quotes["{"] = @('{','}')
	$quotes["["] = @('[',']')
	$quotes["w"] = @("$[({})]-._ '```"", "$[({})]-._ '```"")
	$quotes["W"] = @(' ', ' ')
	$quotes['C'] = @($Caps, $Caps)
	$quote = ([Console]::ReadKey($true)).KeyChar
	if( $quotes.ContainsKey($quote.toString())){
		$Line = $Null
		$Cursor = $Null
		[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$Line,`
				[ref]$Cursor)
		$OpeningQuotes = $quotes[$quote.ToString()][0]
		$ClosingQuotes = $quotes[$quote.ToString()][1]
		if($ClosingQuotes.length -gt 1){
			$EndChar=$Line.indexOfAny($ClosingQuotes, $Cursor)
		}else{
			$EndChar=$Line.indexOf($ClosingQuotes, $Cursor)
		}
		if($OpeningQuotes.length -gt 1){
			$StartChar=$Line.LastIndexOfAny($OpeningQuotes, $Cursor) + 1
		}else{
			$StartChar=$Line.LastIndexOf($OpeningQuotes, $Cursor) + 1
		}
		if($OpeningQuotes.Length -eq 1 -and ( $StartChar -eq 0 -or $EndChar -eq -1)){
			Return
		}
		if($OpeningQuotes.Length -gt 1 -and $EndChar -eq -1){
			$EndChar = $Line.Length
		}
		if( $quote.toString() -eq 'C'){
			$StartChar -= 1
		}
		[Microsoft.PowerShell.PSConsoleReadLine]::Replace($StartChar,`
					$EndChar - $StartChar, '')
		[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($StartChar)
	}
}

function VIChangeOuterBlock(){
	VIDeleteOuterBlock
	[Microsoft.PowerShell.PSConsoleReadLine]::ViInsertMode()
}

function VIDeleteOuterBlock(){
	$quotes = New-Object system.collections.hashtable
	$quotes["'"] = @("'","'")
	$quotes['"'] = @('"','"')
	$quotes["("] = @('(',')')
	$quotes["{"] = @('{','}')
	$quotes["["] = @('[',']')
	$quotes["w"] = @("$[({})]-._ '```"", "$[({})]-._ '```"")
	$quotes["W"] = @(' ', ' ')
	$quote = ([Console]::ReadKey($true)).KeyChar
	if( $quotes.ContainsKey($quote.toString())){
		$Line = $Null
		$Cursor = $Null
		[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$Line,`
				[ref]$Cursor)
		$OpeningQuotes = $quotes[$quote.ToString()][0]
		$ClosingQuotes = $quotes[$quote.ToString()][1]
		if($ClosingQuotes.length -gt 1){
			$EndChar=$Line.indexOfAny($ClosingQuotes, $Cursor) + 1
		}else{
			$EndChar=$Line.indexOf($ClosingQuotes, $Cursor) +1
		}
		if($OpeningQuotes.length -gt 1){
			$StartChar=$Line.LastIndexOfAny($OpeningQuotes, $Cursor)
		}else{
			$StartChar=$Line.LastIndexOf($OpeningQuotes, $Cursor)
		}
		if(($OpeningQuotes.Length -gt 1 -or $quote -eq 'W') -and $EndChar -eq 0){
			$EndChar = $Line.Length 
		}
		if(($OpeningQuotes.Length -gt 1 -or $quote -eq 'W') -and $StartChar -lt 0){
			$StartChar = 0 
		}
		[Microsoft.PowerShell.PSConsoleReadLine]::Replace($StartChar, `
				$EndChar - $StartChar, '')
		[Microsoft.PowerShell.PSConsoleReadLine]::SetCursorPosition($StartChar)
	}
}

function ViChangeSurround(){
	# inspired by tpope vim-surround
	# https://github.com/tpope/vim-surround
	$quotes = @{
		"'" = @("'","'");
		'"'= @('"','"');
		"(" = @('(',')');
		"{" = @('{','}');
		"[" = @('[',']');
	}
	$Line = $Null
	$Cursor = $Null
	$Search = ([Console]::ReadKey($true)).KeyChar
	$Replace = ([Console]::ReadKey($true)).KeyChar
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$Line,`
			[ref]$Cursor)
	$SearchOpeningQuotes = $quotes[$Search.ToString()][0]
	$SearchClosingQuotes = $quotes[$Search.ToString()][1]
	$ReplaceOpeningQuotes = $quotes[$Replace.ToString()][0]
	$ReplaceClosingQuotes = $quotes[$Replace.ToString()][1]
	$EndChar=$Line.indexOf($SearchClosingQuotes, $Cursor)
	$StartChar=$Line.LastIndexOf($SearchOpeningQuotes, $Cursor)
	[Microsoft.PowerShell.PSConsoleReadLine]::Replace($StartChar, `
		1,$ReplaceOpeningQuotes )
	[Microsoft.PowerShell.PSConsoleReadLine]::Replace($EndChar, `
		1,$ReplaceClosingQuotes )
}

function ViDeleteSurround(){
	# inspired by tpope vim-surround
	# https://github.com/tpope/vim-surround
	$quotes = @{
		"'" = @("'","'");
		'"'= @('"','"');
		"(" = @('(',')');
		"{" = @('{','}');
		"[" = @('[',']');
	}
	$Line = $Null
	$Cursor = $Null
	$Search = ([Console]::ReadKey($true)).KeyChar
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$Line,`
			[ref]$Cursor)
	$SearchOpeningQuotes = $quotes[$Search.ToString()][0]
	$SearchClosingQuotes = $quotes[$Search.ToString()][1]
	$EndChar=$Line.indexOf($SearchClosingQuotes, $Cursor)
	$StartChar=$Line.LastIndexOf($SearchOpeningQuotes, $Cursor)
	[Microsoft.PowerShell.PSConsoleReadLine]::Replace($StartChar, `
		1,'')
	[Microsoft.PowerShell.PSConsoleReadLine]::Replace($EndChar - 1, `
		1,'' )
    [Microsoft.PowerShell.PSConsoleReadLine]::Yank
}

function VIGlobalYank (){
	$line = $null
	$cursor = $null 
	[Microsoft.Powershell.PSConsoleReadline]::GetBufferState([ref] $line, [ref] $cursor) 
	Set-Clipboard $line
}

function VIGlobalPaste (){
	param(
		$Before=$false
	)
	$Line = $null
	$Cursor = $null 
	[Microsoft.Powershell.PSConsoleReadline]::GetBufferState([ref] $Line, [ref] $Cursor) 
	if($Before ){
		[Microsoft.Powershell.PSConsoleReadline]::SetCursorPosition($Cursor -1)
	}
	(Get-Clipboard).Split("`n") |% {
		[Microsoft.Powershell.PSConsoleReadline]::Insert( `
				$_.Replace("`t",'  ') + "`n" )
	}
}

Set-PSReadLineKeyHandler -Chord "c,i" -ViMode Command -ScriptBlock { & VIChangeInnerBlock }
Set-PSReadLineKeyHandler -Chord "c,a" -ViMode Command -ScriptBlock { & VIChangeOuterBlock }
Set-PSReadLineKeyHandler -Chord "d,i" -ViMode Command -ScriptBlock { & VIDeleteInnerBlock }
Set-PSReadLineKeyHandler -Chord "d,a" -ViMode Command -ScriptBlock { & VIDeleteOuterBlock }
Set-PSReadLineKeyHandler -Chord "c,s" -ViMode Command -ScriptBlock { & VIChangeSurround }
Set-PSReadLineKeyHandler -Chord "d,s" -ViMode Command -ScriptBlock { & VIDeleteSurround }
Set-PSReadLineKeyHandler -Chord "Ctrl+a" -ViMode Command -ScriptBlock { VIIncrement $args[0] $args[1] }
Set-PSReadLineKeyHandler -Chord "Ctrl+x" -ViMode Command -ScriptBlock { VIDecrement $args[0] $args[1] }
Set-PSReadLineKeyHandler -Chord "+,y" -ViMode Command -ScriptBlock { VIGlobalYank }
Set-PSReadLineKeyHandler -Chord "+,p" -ViMode Command -ScriptBlock { VIGlobalPaste }
Set-PSReadLineKeyHandler -Chord "+,P" -ViMode Command -ScriptBlock { VIGlobalPaste $true }
