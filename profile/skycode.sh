#!/usr/bin/env bash
set -euo pipefail

SESSION_PREFIX="skycode"

usage() {
  cat <<EOF
Usage:
  $0 -s [-p PORT]        # stop mode
  $0 -u USER -p PORT     # start mode (no reservation, partition, or node)
EOF
  exit 1
}

# Defaults
STOP=false
PORT=

while getopts "su:p:" opt; do
  case $opt in
    s) STOP=true ;;
    u) USERNAME=$OPTARG ;;
    p) PORT=$OPTARG ;;
    *) usage ;;
  esac
done

# Stop mode
if $STOP; then
  echo -e "\n💻 Stopping any existing ${SESSION_PREFIX} sessions…"
  for ses in $(screen -ls | awk "/\\.${SESSION_PREFIX}.*${SESSION_PREFIX}/ {print \$1}"); do
    echo -e "\n💻 Killing session $ses"
    screen -S "$ses" -X quit
  done
  if [[ -n "$PORT" ]]; then
    echo -e "\n💻 Killing any SSH tunnels on port $PORT"
    pkill -f "ssh .*127\.0\.0\.1:${PORT}"
  else
    echo -e "\n💻 No port specified; skipping SSH tunnel cleanup"
  fi
  echo -e "\n Okay Bye 👋 \n"
  exit 0
fi

# Start mode: require username and port
[[ -n "${USERNAME-}" && -n "${PORT-}" ]] || usage

SSH_CONFIG="$HOME/.ssh/config"
HOST_ALIAS="skycode-worker"
HOST_ENTRY="Host ${HOST_ALIAS}
  HostName localhost
  User ${USERNAME}
  Port ${PORT}"

if ! grep -q "^Host ${HOST_ALIAS}\$" "$SSH_CONFIG" 2>/dev/null; then
  echo -e "\n💻 Adding SSH host entry '${HOST_ALIAS}' to $SSH_CONFIG"
  printf "\n%s\n" "$HOST_ENTRY" >> "$SSH_CONFIG"
else
  echo -e "\n💻 SSH config entry '${HOST_ALIAS}' already present, skipping"
fi

SESSION="skycode_auto_skycode"

echo -e "\n💻 Starting screen session '${SESSION}'"
screen -dmSL "$SESSION"

# Auto node allocation (no reservation, partition, or nodelist)
REMOTE_CMD="source /etc/profile && module load slurm && \
srun --pty \
     --job-name=sky-${USERNAME} \
     --nodes=1 --ntasks=1 \
     ssh -N -R 127.0.0.1:${PORT}:127.0.0.1:22 ${USERNAME}@leia1"

CMD0="ssh -t ${USERNAME}@skyriver.nri.bcm.edu \"${REMOTE_CMD}\""

echo -e "\n💻 Starting SSH job on any available node"
screen -S "$SESSION" -X screen bash -c "$CMD0 >~/logs/${SESSION}_win0.log 2>&1; exec bash"

CMD1="ssh -N -L ${PORT}:127.0.0.1:${PORT} ${USERNAME}@skyriver.nri.bcm.edu"
screen -S "$SESSION" -X screen bash -c "$CMD1 >~/logs/${SESSION}_win1.log 2>&1; exec bash"

echo -e "\n💻 Tunnel setup complete: Node:Port → Headnode:${PORT} → Your laptop"
echo -e "\n⏳ On http://skyriver.nri.bcm.edu:4200/#/status, wait until your job is RUNNING"
echo -e "\n💻 Open VS Code → SSH to host alias '${HOST_ALIAS}'"
echo -e "\n Okay Bye 👋 \n"
