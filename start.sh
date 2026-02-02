#!/bin/bash
cd /root/sre-tycoon

# Check if already running
PID=$(lsof -ti :89 2>/dev/null)
if [ -n "$PID" ]; then
  echo "Port 88 already in use (PID: $PID). Stop it first with ./stop.sh"
  exit 1
fi

echo "Starting SRE Tycoon on port 88..."
export RAILS_ENV=production
export SECRET_KEY_BASE=$(cat /root/sre-tycoon/.secret_key_base 2>/dev/null || ruby -e "require 'securerandom'; puts SecureRandom.hex(64)")
export RAILS_LOG_TO_STDOUT=1

# Save secret key if not saved
if [ ! -f /root/sre-tycoon/.secret_key_base ]; then
  echo "$SECRET_KEY_BASE" > /root/sre-tycoon/.secret_key_base
fi

nohup bundle exec rails server -b 127.0.0.1 -p 89 -e production > /root/sre-tycoon/log/production.log 2>&1 &
echo $! > /root/sre-tycoon/tmp/pids/server.pid

sleep 2

if lsof -ti :89 > /dev/null 2>&1; then
  echo "SRE Tycoon started! PID: $(cat /root/sre-tycoon/tmp/pids/server.pid)"
else
  echo "Failed to start. Check log/production.log"
  cat /root/sre-tycoon/log/production.log | tail -20
  exit 1
fi
