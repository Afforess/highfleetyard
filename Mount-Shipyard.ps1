<#

.SYNOPSIS

Creates a Symlink from the highfleetyard to the Ships folder in your Highfleet installation, or removes said symlink.

.DESCRIPTION

Creates a Symlink from the highfleetyard to the Ships folder in your Highfleet installation. If -Unmount is passed it will removes said symlink. This backsup the Ships folder to .Ships.Old when mounting and restores it when unmounting.

.PARAMETER ShipsPath
The path to the Ships folder within your HighFleet installation. 
If this isn't passed it will open a folder browser prompt asking you to select your Ships folder within your HighFleet installation.

.PARAMETER Unmount
Whether to remove the symlink and restore the .Ships.Old folder

.EXAMPLE

PS> .\Mount-Shipyard

Opens a folder browser and creates a symlink between the current folder and the selected folder from the browser window. Backsup the selected folder as .Ships.Old and marks it as hidden.

.EXAMPLE

PS> .\Mount-Shipyard -Unmount

Opens a folder browser and removes the selected symlink from the browser window. Restores the .Ships.Old as the selected folder.

.EXAMPLE

PS> .\Mount-Shipyard -ShipsPath "D:\Steam\steamapps\common\HighFleet\Ships"

Creates a symlink between the current folder and the folder path passed as -ShipsPath. Backsup the passed folder as .Ships.Old and marks it as hidden.

.EXAMPLE

PS> .\Mount-Shipyard -ShipsPath "D:\Steam\steamapps\common\HighFleet\Ships" -Unmount

Removes the symlink at the passed as -ShipsPath. Restores the .Ships.Old as the passed folder.

.NOTES

Author: Arrorn
Version: 1.0.0
Updated: 09/16/2021

.LINK

https://github.com/Afforess/highfleetyard

#>

param
(
    [Parameter(mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ShipsPath,
    [Parameter(mandatory = $false)]
    [switch]$Unmount
)

<#

.SYNOPSIS

Mounts current folder to HighFleets Ship folder

#>
Function Mount-Shipyard
{
    param
    (
        [Parameter(mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ShipsPath,
        [Parameter(mandatory = $false)]
        [switch]$Unmount
    )
    $oldshipsName = ".Ships.Old"
    $shipsName = "Ships"
    if(-Not ($ShipsPath -and (Test-Path -Path $ShipsPath)))
    {
        $shipsDir = (new-object -COM 'Shell.Application').BrowseForFolder(0,'Please select the Ship folder in your Highfleet installation.',0,0).self.path
        if(-Not $shipsDir)
        {
            Exit
        }
    }
    else
    {
        $shipsDir = $ShipsPath
    }
    $installDir = Split-Path -Path $shipsDir -Parent
    $oldshipsDir = Join-Path -Path $installDir -ChildPath $oldshipsName

    if($Unmount -ne $true)
    {
        Rename-Item -Path $shipsDir -NewName $oldshipsName
        (Get-Item $oldshipsDir -Force).Attributes += 'Hidden'
        New-Item -ItemType SymbolicLink -Path $shipsDir -Value $PSScriptRoot
    }
    else
    {
        if((Get-Item $shipsDir -Force).LinkType -eq "SymbolicLink")
        {
            (Get-Item $shipsDir -Force).Delete()
            Rename-Item -Path $oldshipsDir -NewName $shipsName
            (Get-Item $shipsDir -Force).Attributes -= 'Hidden'
        }
    }
}

Mount-Shipyard @PSBoundParameters