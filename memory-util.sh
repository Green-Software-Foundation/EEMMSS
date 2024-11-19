#!/bin/bash

# Fetches memory utilization accurately across macOS, Linux, and Windows
get_memory_usage() {
    case "$(uname -s)" in
        Darwin)
            # Calculate memory utilization on macOS using active app memory, wired memory, and compressed memory
            vm_stat | awk '
            /Pages free/ {free=$3} 
            /Pages active/ {active=$3} 
            /Pages speculative/ {speculative=$3} 
            /Pages wired down/ {wired=$3} 
            /Pages compressed/ {compressed=$3} 
            END {
                used=active+wired+compressed;
                total=used+free+speculative;
                printf "Memory Utilization: %.2f%%\n", (used / total) * 100
            }'
            ;;
        Linux)
            # For Linux
            MemFree=$(cat /proc/meminfo | grep -i MemFree | awk '{print $2}')
            Buffers=$(cat /proc/meminfo | grep -i Buffers | awk '{print $2}')
            Cached=$(cat /proc/meminfo | grep -i Cached | grep -v SwapCached | awk '{print $2}')
            MemTotal=$(cat /proc/meminfo | grep -i MemTotal | awk '{print $2}')

            ramperutil=$(echo "scale=4; ($MemTotal - $MemFree - $Buffers - $Cached) / $MemTotal * 100" | bc)

            printf "Memory Utilization: %.2f%%\n" "$ramperutil"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            # For Windows CMD or PowerShell
            if command -v wmic &> /dev/null; then
                wmic OS get FreePhysicalMemory,TotalVisibleMemorySize /Value | awk -F "=" '
                /TotalVisibleMemorySize/ {total=$2} 
                /FreePhysicalMemory/ {free=$2} 
                END {used=total-free; printf "Memory Utilization: %.2f%%\n", (used / total) * 100}'
            else
                powershell -Command "Get-Counter '\Memory\% Committed Bytes In Use' | ForEach-Object {Write-Output ('Memory Utilization: ' + $_.CounterSamples.CookedValue + '%')}"
            fi
            ;;
        *)
            echo "Unsupported OS"
            exit 1
            ;;
    esac
}

# Fetches memory utilization every 5 seconds
while true; do
    get_memory_usage
    sleep 5
done
