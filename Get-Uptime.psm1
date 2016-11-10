<#
.Synopsis
   Returns uptime from local or remote machine. 
.DESCRIPTION
   Uses WMI call to retrive uptime. Get-WmiObject -Class Win32_OperatingSystem
.EXAMPLE
Get-Uptime -ComputerName da12345, localhost, blah -Verbose

VERBOSE: blah does not reply to ping
Online ComputerName TotalDays TotalHours
------ ------------ --------- ----------
  True da42323      1,2       28,89
  True localhost    3,07      73,59
 False blah         n/a       n/a

.EXAMPLE
Get-Uptime

Online ComputerName TotalDays TotalHours
------ ------------ --------- ----------
  True localhost    3,07      73,72

.EXAMPLE
'localhost', 'NonExistingPC', '127.0.0.1' | Get-Uptime

Online ComputerName  TotalDays TotalHours
------ ------------  --------- ----------
  True localhost     2,95      70,87
 False NonExistingPC n/a       n/a
  True 127.0.0.1     2,95      70,87

#>
function Get-Uptime
{
    [CmdletBinding()]
    [Alias()]
    Param
    (
        # List of ComputerNames 
        [Parameter(Mandatory=$false,
                   ValueFromPipelineByPropertyName=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [string[]]
        $ComputerName = 'localhost'
    )

    Begin
    {}
    Process
    {

        Foreach($Computer in $ComputerName) {
        
            If(Test-Connection -ComputerName $Computer -Count 1 -Quiet) {
                try
                {

                    $wmi = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $Computer

                    New-Object psobject -Property @{ComputerName=$Computer;
                                                    TotalHours=((($wmi.ConvertToDateTime($wmi.LocalDateTime) - $wmi.ConvertToDateTime($wmi.LastBootUpTime))).TotalHours).tostring("##.##"); 
                                                    TotalDays=(($wmi.ConvertToDateTime($wmi.LocalDateTime) - $wmi.ConvertToDateTime($wmi.LastBootUpTime))).TotalDays.tostring("##.##");
                                                    Online=$true;
                                                   }

                }
                catch [System.UnauthorizedAccessException]
                {
                    Write-Error "Access denied to $Computer"
                    New-Object psobject -Property @{ComputerName=$Computer;
                                    TotalHours='n/a'; 
                                    TotalDays='n/a';
                                    Online=$true;
                                    }
                }
                catch [Exception]
                {
                    Write-Error "WMI call to $Computer failed"
                    New-Object psobject -Property @{ComputerName=$Computer;
                                    TotalHours='n/a'; 
                                    TotalDays='n/a';
                                    Online=$true;
                                    }
                }

            } else {
                Write-Verbose "$Computer does not reply to ping"
                New-Object psobject -Property @{ComputerName=$Computer;
                                                TotalHours='n/a'; 
                                                TotalDays='n/a';
                                                Online=$false;
                                               }

            }
        } # End foreach
    }
    End
    {}
}