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
            # For Git Bash (Windows with WSL)
            grep -m 1 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5); printf "CPU Utilization: %.2f%\n", usage}'
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
