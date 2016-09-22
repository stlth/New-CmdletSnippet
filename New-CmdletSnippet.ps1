<#
.VERSION 1.0.0
.GUID 9e2821f7-8662-4d03-b83b-d41fe1d12819
.AUTHOR Cory Calahan
.COMPANYNAME
.COPYRIGHT (C) Cory Calahan. All rights reserved.
.TAGS Metadata,Cmdlet,Snippet
.LICENSEURI
.PROJECTURI
    https://github.com/stlth/New-CmdletSnippet
.ICONURI
.EXTERNALMODULEDEPENDENCIES 
.REQUIREDSCRIPTS 
.EXTERNALSCRIPTDEPENDENCIES 
.RELEASENOTES
.Synopsis
    Generates a code snippet for a new command for custom modifications.
.DESCRIPTION
    Generates a code snippet from an existing PowerShell cmdlet's metadata for custom modifications.
.EXAMPLE
    PS> New-CmdletSnippet -FromCmdlet 'Test-Connection'
#>
function New-CmdletSnippet
{
#Requires -Version 5
    [CmdletBinding()]
    [Alias()]
    [OutputType([String])]
    Param
    (
        # An existing PowerShell cmdlet to copy metadata from
        [Parameter(Mandatory=$true,
                   ValueFromPipelineByPropertyName=$true,
                   Position=0)]
        [ValidateScript({return (Get-Command -Name $PSItem)})]
        [string[]]
        $FromCmdlet,        
        # Option to copy snippet directly to the system clipboard
        [Parameter(Mandatory=$false,
                    Position=1)]
        [switch]
        $CopyToClipboard,
        # Option to output snippet to Container (folder) as <snippet>.ps1 file
        [Parameter(Mandatory=$false,
                    Position=2)]
        [ValidateScript({return (Test-Path -Path $PSItem -PathType 'Container')})]
        [string]
        [Alias('ToFolder')]
        $ToContainer
    )

    Begin
    {
        Write-Verbose -Message 'Listing Parameters utilized:'
        $PSBoundParameters.GetEnumerator() | ForEach-Object { Write-Verbose -Message "$($PSItem)" }
    }
    Process
    {
        foreach ($cmdlet in $FromCmdlet)
        {
            $MetaData = New-Object -TypeName 'System.Management.Automation.CommandMetaData' -ArgumentList (Get-Command -Name $cmdlet)
            $ProxyCommand = [System.Management.Automation.ProxyCommand]::Create($MetaData)
            $OutputString = New-Object -TypeName 'System.Text.StringBuilder'
            $header = "function $($cmdlet)Custom`r`n{`r`n<# Generated on $(Get-Date) from '$cmdlet'. #>`r`n"
            $footer = "`n}"
            $OutputString.Append($header).Append($ProxyCommand.ToString()).Append($footer) | Out-Null
            if ($PSBoundParameters['CopyToClipBoard'])
            {
                $($OutputString.ToString()) | Set-Clipboard
            }       
            if ($PSBoundParameters['ToContainer'])
            {
                Write-Verbose -Message "Output to file: '$OutFile'."
                try
                {
                    New-Item -Path $ToContainer -Name "$($cmdlet)Custom.ps1" -Value "$($OutputString.ToString())" -ErrorAction 'Stop' | Out-Null
                }
                catch
                {
                    Write-Error -Message $PSItem
                    break
                }
            }
            Write-Output -InputObject $($OutputString.ToString())
        }
    }
    End
    {
    }
}