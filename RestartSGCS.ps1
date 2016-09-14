<#
.NAME
Restart SGCS

.SYNOPSIS

Restarts the SGCS service.

.DESCRIPTION

This script requests the service ticket number for the reboot, the performs a stop/start of the LS Gate Control Service.  

.PARAMETER
-Debug
.EXAMPLE

RestartSGCS.ps1

.EXAMPLE
RestartSGCS.ps1 -Debug
#>
[CmdletBinding()]
Param (
    [string]$TicketNumber = $(Read-Host "Enter the service ticket number")

    )


#Set flags for debug mode.    
If($psBoundParameters['debug'])
    {
    $DebugPreference = "Continue"
    }
Else
    {
    $DebugPreference = "SilentlyContinue"
    }



Enter-PSSession sgcs.security.local
Write-Debug -Message "Executing command to stop the service"
Write-EventLog -LogName Application -Source "LS Gate Service Team Stop" -EventId 99 -EntryType Information -Message "The service team has stopped the LS Gate Control Service.  Please reference ticket number $TicketNumber"
#Stopping then starting the service so that we get the stop and start messages and can add a 10 second delay.  A restart is just too fast.  
Stop-Service "LS Gate Control Service"
$status = Get-Service "LS Gate Control Service" | Select Status
Write-Debug -Message "The service is currently in $Status Status"
While ($status -ine "Stopped")
    {
    Write-Debug -Message "The service did not stop as expected.  Attempting to force"
    Stop-Service "LS Gate Control Service" -Force
    $status = Get-Service "LS Gate Control Service" | Select Status
    }
Write-Debug -Message "Pausing for 10 seconds"
Start-Sleep 10
Write-Debug -Message "Starting the LS Gate Control Service"

Start-Service "LS Gate Control Service"
Write-EventLog -LogName Application -Source "LS Gate Service Team Start" -EventId 99 -EntryType Information -Message "The service team has stopped the LS Gate Control Service.  Please reference ticket number $TicketNumber"
$status = Get-Service "LS Gate Control Service" | Select Status

Write-Debug -Message "The service is currently in $Status Status"
Exit-PSSession

Exit