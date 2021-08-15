#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Launch the bars
echo "---" | tee -a /tmp/polybar1.log
#polybar example 2>&1 | tee -a /tmp/polybar1.log & disown

# Add polybar to every monitor
for m in $(polybar --list-monitors | cut -d":" -f1); do
    MONITOR=$m polybar --reload example 2>&1 | tee -a /tmp/polybar1.log & disown
done

echo "Bars launched..."
