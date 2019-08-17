class Logger {
    [bool]$LogToConsole = $true
    [bool]$LogToFile = $true
    [string]$LogFile
    [string]$Indentifer
    [string[]]$FileBuffer
    [string[]]$ConsoleBuffer
    [string]$ConsoleFormat = "DHUILM"
    [string]$FileFormat = "DHUILM"
    [string]$DateFormat = "yyyy-MM-dd HH:mm:ss.fff"
    [string]$FieldDelimiter = "`t"
    [Hashtable]$ColorMap = @{
        Info =    [System.ConsoleColor]::White
        Warning = [System.ConsoleColor]::Yellow
        Error =   [System.ConsoleColor]::Red
    }
    Logger([string]$logfilename, [string]$identifier){
        $this.Indentifer = $identifier
        $this.LogFile = $logfilename
    }
    Logger([string]$logfilename, [string]$identifier, [bool]$logtofile, [bool]$logtoconsole){
        $this.Indentifer = $identifier
        $this.LogFile = $logfilename
        $this.LogToConsole = $logtoconsole
        $this.LogToFile = $logtofile
    }
    Info([object]$message){ $this.WriteLogLine($message, "Info") }
    Warning([object]$message){ $this.WriteLogLine($message, "Warning") }
    Error([object]$message){ $this.WriteLogLine($message, "Error") }
    [string]GetLine([object]$item, [string]$format, [string]$level){
        $values = @()
        foreach($char in $format.ToCharArray()){
            switch ($char) {
                'D' { $values += Get-Date -Format $this.DateFormat }
                'H' { $values += [Environment]::MachineName }
                'U' { $values += [Environment]::UserName  }
                'I' { $values += $this.Indentifer }
                'L' { $values += $level }
                'M' { $values += $item.Trim() }
                Default {}
            }
        }
        return ($values -join $this.FieldDelimiter)
    }
    WriteLogLine([object]$message, [string]$level){
        if($this.LogToConsole){
            foreach($obj in $message) {
                $line = $this.GetLine($obj, $this.ConsoleFormat, $level)
                Write-Host -ForegroundColor $this.ColorMap[$level] -Object $line
                $this.ConsoleBuffer += $line
            }
        }
        if($this.LogToFile){
            foreach($obj in $message) {
                $line = $this.GetLine($obj, $this.FileFormat, $level)
                Add-Content -Value $line -Path $this.LogFile
                $this.FileBuffer += $line
            }
        }
    }
}