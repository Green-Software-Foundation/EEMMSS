#!/bin/bash

# Fetches CPU utilization
get_cpu_usage() {
    case "$(uname -s)" in
        Linux)
            # For Linux
            top -b -n1 | awk '/Cpu\(s\):/ {print "CPU Utilization:", $2 + $4 "%"}'
            ;;
        Darwin)
            # For macOS
            top -l 1 | awk '/CPU usage:/ {print "CPU Utilization:", $3}'
            ;;
        CYGWIN*|MINGW*|MSYS*)
            # For Windows CMD or PowerShell
            if command -v wmic &> /dev/null; then
                # If CMD or PowerShell
                wmic cpu get loadpercentage | awk 'NR>1 {print "CPU Utilization:", $1"%"}'
            else
                # Fallback for Windows PowerShell (without WSL)
                powershell -Command "Get-Counter -Counter '\Processor(_Total)\% Processor Time' | ForEach-Object {Write-Output ('CPU Utilization: ' + $_.CounterSamples.CookedValue + '%')}"
            fi
            ;;
        *)
            echo "Unsupported OS"
            exit 1
            ;;
    esac
}

# Fetches CPU utilization every 5 seconds
while true; do
    get_cpu_usage
    sleep 5
done