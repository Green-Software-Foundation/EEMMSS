#!/bin/bash

# Fetches memory utilization accurately across macOS, Linux, and Windows
get_memory_usage() {
    case "$(uname -s)" in
        Darwin)
            # Extract memory metrics from vm_stat
            free=$(vm_stat | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
            active=$(vm_stat | grep "Pages active" | awk '{print $3}' | sed 's/\.//')
            inactive=$(vm_stat | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
            wired=$(vm_stat | grep "Pages wired down" | awk '{print $4}' | sed 's/\.//')
            compressed=$(vm_stat | grep "Pages stored in compressor" | awk '{print $5}' | sed 's/\.//')
            # Get page size in bytes
            page_size=$(vm_stat | grep "page size of" | awk '{print $8}')
            # Calculate physical memory in MB
            total_memory=$(( ($free + $active + $inactive + $wired + $compressed) * $page_size / 1024 / 1024 ))
            # Calculate used memory in MB
            used_memory=$(( ($active + $wired + $compressed) * $page_size / 1024 / 1024 ))
            # Calculate available memory in MB
            available_memory=$(( ($free + $inactive) * $page_size / 1024 / 1024 ))
            # Calculate memory utilization percentage
            memory_utilization=$(echo "scale=2; $used_memory / $total_memory * 100" | bc)

            # Output results
            printf "Memory Utilization: %.2f%%\n" "$memory_utilization"
            ;;
        Linux)
            # Extract memory metrics from /proc/meminfo
            MemFree=$(cat /proc/meminfo | grep -i MemFree | awk '{print $2}')
            Buffers=$(cat /proc/meminfo | grep -i Buffers | awk '{print $2}')
            Cached=$(cat /proc/meminfo | grep -i Cached | grep -v SwapCached | awk '{print $2}')
            MemTotal=$(cat /proc/meminfo | grep -i MemTotal | awk '{print $2}')
            # Calculate memory utilization percentage
            memory_utilization=$(echo "scale=4; ($MemTotal - $MemFree - $Buffers - $Cached) / $MemTotal * 100" | bc)

            printf "Memory Utilization: %.2f%%\n" "$memory_utilization"
            ;;
        CYGWIN*|MINGW*|MSYS*)
            # For Git Bash on Windows
            memory_utilization=$(powershell -Command "(Get-Counter '\Memory\% Committed Bytes In Use').CounterSamples.CookedValue")
            rounded_memory_utilization=$(echo "$memory_utilization" | awk '{printf "%.2f", $1}')
            printf "Memory Utilization: %.2f%%\n" "$rounded_memory_utilization"
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
