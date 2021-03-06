<#
    .SYNOPSIS
    Add or remove the current script folder to/from the list of persistent PowerShell mdoules
   
   	Thomas Stensitzki
	
	THIS CODE IS MADE AVAILABLE AS IS, WITHOUT WARRANTY OF ANY KIND. THE ENTIRE 
	RISK OF THE USE OR THE RESULTS FROM THE USE OF THIS CODE REMAINS WITH THE USER.
	
	Version 1.0, 2015-06-10

    Ideas, comments and suggestions to support@granikos.eu 
	
    .DESCRIPTION
	
    This script adds or removes to/from the registry key HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment\PSModulePath 

    Adding the folder to the list of persistent PowerShell module paths is required to provide access across all PowerShell sessions

    .NOTES 
    Requirements 
    - Windows Server 2012/2012 R2
    - Windows Server 2008/2008 R2

    Revision History 
    -------------------------------------------------------------------------------- 
    1.0     Initial community release 

    .PARAMETER Add
    Add the current script folder to the list of persistent PowerShell modules paths	

    .PARAMETER Remove
    Remove the current script folder from the list of persistent PowerShell modules paths	

    .EXAMPLE
    Add the current script folder
    .\Set-PersitentPSModulePath.ps1 -Add

    .EXAMPLE
    Remove the current script folder
    .\Set-PersitentPSModulePath.ps1 -Remove

    #>

Param(
    [parameter(Mandatory=$false,ValueFromPipeline=$false)][switch]$Add,
    [parameter(Mandatory=$false,ValueFromPipeline=$false)][switch]$Remove
)

Set-StrictMode -Version Latest

$currentPSModulePaths = [string](Get-ItemProperty -Path �Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment� -Name PSModulePath).PSModulePath

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path

Write-Host "Current PSModulePath(s): $($currentPSModulePaths)"

function Request-Choice {
    param([string]$Caption)
    $choices =  [System.Management.Automation.Host.ChoiceDescription[]]@("&Yes","&No")
    [int]$defaultChoice = 1

    $choiceReturn = $Host.UI.PromptForChoice($Caption, "", $choices, $defaultChoice)

    return $choiceReturn   
}

if($Add) {

    if($currentPSModulePaths.Contains($ScriptDir)) {
        Write-Host "The current script directory has already been added to the PSModulePath variable."
        Write-Host "Use Set-PersistentPSModulePath.ps1 -Remove to remove the module path!" 
        exit 0
    }
    
    Write-Host "Path to add: $($ScriptDir)"

    if((Request-Choice -Caption "Do you want to add the script folder to the persistent list of PowerShell Modules?") -eq 0) {
        
        Write-Host "Adding $($ScriptDir)"

        $newPSModulesPath=$currentPSModulePaths + ";$($ScriptDir)\"

        Write-Host "New PSModulePaths: $($newPSModulesPath)"

        Set-ItemProperty -Path �Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment� -Name PSModulePath �Value $newPSModulesPath
    }
}

if($Remove) {

    if(!$currentPSModulePaths.Contains($ScriptDir)) {
        Write-Host "The current script directory has not been added to the PSModulePath variable."
        Write-Host "Use Set-PersistentPSModulePath.ps1 -Add to add the module path!" 
        exit 0
    }

    Write-Host "Path to remove: $($ScriptDir)"

    if((Request-Choice -Caption "Do you want to remove the script folder from the persistent list of PowerShell Modules?") -eq 0) {
        
        Write-Host "Removing $($ScriptDir)"

        $newPSModulesPath=$currentPSModulePaths.Replace(";$($ScriptDir)\","")

        Write-Host "New PSModulePath(s): $($newPSModulesPath)"

        Set-ItemProperty -Path �Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment� -Name PSModulePath �Value $newPSModulesPath
    }
}