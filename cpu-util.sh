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
            # For Git Bash on Windows
            if command -v wmic &> /dev/null; then
                wmic cpu get loadpercentage | awk 'NR>1 && $1 ~ /^[0-9]+$ {print "CPU Utilization:", $1"%"}'
            else
                echo "Error: wmic is not available. Ensure your environment supports it."
                exit 1
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
