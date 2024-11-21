#!/bin/bash

# Fetches CPU utilization dynamically
get_cpu_usage() {
    case "$(uname -s)" in
        Linux|CYGWIN*|MINGW*|MSYS*)
            # Read the first snapshot
            read -r cpu prev_user prev_nice prev_system prev_idle < /proc/stat

            # Wait for 1 second
            sleep 1

            # Read the second snapshot
            read -r cpu user nice system idle < /proc/stat

            # Calculate deltas
            idle_delta=$((idle - prev_idle))
            total_delta=$(( (user - prev_user) + (nice - prev_nice) + (system - prev_system) + idle_delta ))

            # Calculate CPU utilization percentage
            usage=$(awk "BEGIN {printf \"%.2f\", (1 - idle_delta / total_delta) * 100}")
            echo "CPU Utilization: $usage%"
            ;;
        Darwin)
            # For macOS
            top -l 1 | awk '/CPU usage:/ {print "CPU Utilization:", $3}'
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
