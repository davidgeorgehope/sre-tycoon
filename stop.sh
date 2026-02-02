#!/bin/bash
echo "Stopping SRE Tycoon on port 88..."

PID=$(lsof -ti :89 2>/dev/null)
if [ -n "$PID" ]; then
  kill $PID 2>/dev/null
  sleep 1
  # Force kill if still running
  if lsof -ti :89 > /dev/null 2>&1; then
    kill -9 $(lsof -ti :89) 2>/dev/null
  fi
  echo "Stopped (PID: $PID)"
else
  echo "Not running on port 88."
fi

# Clean up pid file
rm -f /root/sre-tycoon/tmp/pids/server.pid
