# Load posh-git example profile
. "$env:USERPROFILE\Documents\WindowsPowerShell\posh-git\profile.example.ps1"
Import-Module PsGet
Import-Module PSReadline
# Ctrl-T mapped to autocomplete
Set-PSReadLineKeyHandler -Key (DC4 Removed) -Function HistorySearchBackward

$env:PATH ="$env:PATH;C:\Program Files\Microsoft Team Foundation Server 14.0\Tools"

function s {
    . "C:\Program Files\Everything\Everything.exe" -search $args
}

function repo {
    $save = $args
    Get-ChildItem -Attributes Directory | ForEach-Object {
        pushd $_.Name
        Write-Host "Repo:" $_.Name
        git.exe $save
        popd
    }
}

function deployCd
{
    foreach ($number in (1..600)) { 
        try { 
            Copy-Item D:\Tools\CreateDrop\CreateDrop\bin\Release\CreateDrop.exe \\ddfiles\airstream\tfs\Tools\CreateDrop\ -Force 
            Copy-Item D:\Tools\CreateDrop\CreateDrop\bin\Release\CreateDrop.pdb \\ddfiles\airstream\tfs\Tools\CreateDrop\ -Force; 
            echo "Deployed CreateDrop successfully."
            return 
        } catch { 
            echo $_.Exception.Message; 
            echo "Attempt ${number}: Waiting 1s..."
            sleep 1; 
        }
    }
}

function dfui 
{ 
    . "C:\Program Files\Microsoft SDKs\Azure\Emulator\dfui.exe" 
}

function dsi 
{
    sqlcmd -S kedavid-server -i $profile\..\scorched_earth.sql
    . "C:\Program Files\Microsoft SDKs\Azure\Emulator\csrun.exe" /removeAll
    . "C:\Program Files (x86)\Microsoft SDKs\Azure\Storage Emulator\WAStorageEmulator.exe" stop
    . "C:\Program Files (x86)\Microsoft SDKs\Azure\Storage Emulator\WAStorageEmulator.exe" init -forcecreate
}

function ud
{
    . "D:\Tools\UpdateDeployments\UpdateDeployments\bin\Debug\UpdateDeployments.exe" kedavid-server
}

function .. 
{
    cd ..
}

function npp
{ 
    . "c:\Program Files (x86)\Notepad++\notepad++.exe" $args 
}

function pp 
{ 
    msbuild /t:PublishPartition dirs.proj 
}

function git 
{ 
    . "C:\Program Files (x86)\Git\bin\git.exe" $args 
}

function devenv 
{
    # launch via explorer so we don't get the current environment setup (e.x. razzle)
    explorer "C:\program files (x86)\Microsoft visual studio 14.0\common7\ide\devenv.exe" $args 
}

function ev
{
    eventvwr
}

function ie
{
    . "C:\Program Files\Internet Explorer\iexplore.exe"
}

function st
{
    start .
}

function dcr
{
    vssdf cr $args
    ud 
}

function ucr
{
    vssdf cr -update $args
    ud
}

function mytestdeploy
{
    $sqlSettings = "SET AO_SQL_NAMEDINSTANCE=kedavid-server`nSET AO_EXISTING_RSURL=http://kedavid-server/ReportServer`nSET AO_EXISTING_RSADMINURL=http://kedavid-server/Reports`n"
    $testDeploy = which testdeploy
    $newTestDeploy = "$testDeploy.new"
    Set-Content $newTestDeploy "" 
    Get-Content $testdeploy | ForEach-Object { if ($_ -eq "set SCRIPTDIR=%~dp0") { $_ = "$_`n$sqlSettings" }; Add-Content $newTestDeploy $_; }
    Move-Item $newTestDeploy $testDeploy -Force
    testdeploy
}

## vscs helpers
# Gets the latest buildable tag found at or below the given branch name. Defaults to origin/master
function latestBuildable($branch="origin/master")
{
   $branchName =  $branch
   if($branchName.StartsWith("origin/"))
   {
     $branchName = $branchName.Substring("origin/".Length)
   }
   
   git describe --tags --abbrev=0 --match Buildable/$branchName/* $branch
}
 
 # Gets the latest selftest tag found at or below the given branch name. Defaults to origin/master
function latestSelfTest($branch="origin/master") 
{
   $branchName =  $branch
   if($branchName.StartsWith("origin/"))
   {
     $branchName = $branchName.Substring("origin/".Length)
   }
   
   git describe --tags --abbrev=0 --match SelfTest/$branchName/* $branch
}
 
 # Rebase the given branch into the current one from the most recent buildable tag
function rebaseLatestBuildable($branch="origin/master") {
   Write-Host "Fetching..."
   git fetch
   
   Write-Host "Finding last building tag for $branch"
   $tag = latestBuildable $branch
   
   Write-Host "Rebase current branch onto $tag"
   git rebase $tag
}
 
# Short aliases of the above functions
Set-Alias n npp -scope Global -option AllScope
Set-Alias rlb rebaseLatestBuildable -scope Global -option AllScope
Set-Alias lb latestBuildable -scope Global -option AllScope
Set-Alias lst latestSelfTest -scope Global -option AllScope
Set-Alias which where.exe

