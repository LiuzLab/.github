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

  # List tmux sessions and kill any with the prefix in the name
  if tmux ls >/dev/null 2>&1; then
    while IFS=: read -r ses _; do
      if [[ "$ses" == *"$SESSION_PREFIX"* ]]; then
        echo -e "\n💻 Killing session $ses"
        tmux kill-session -t "$ses" || true
      fi
    done < <(tmux ls 2>/dev/null)
  else
    echo -e "\n💻 No tmux server or sessions found"
  fi

  if [[ -n "${PORT-}" ]]; then
    echo -e "\n💻 Killing any SSH tunnels on port $PORT"
    pkill -f "ssh .*127\.0\.0\.1:${PORT}" || true
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

echo -e "\n💻 Starting tmux session '${SESSION}'"
# Create a detached tmux session with a placeholder window
tmux new-session -d -s "$SESSION" -n placeholder "bash -lc 'echo Session started; exec bash'"

# Auto node allocation (no reservation, partition, or nodelist)
REMOTE_CMD="source /etc/profile && module load slurm && \
srun --pty \
     --job-name=sky-${USERNAME} \
     --nodes=1 --ntasks=1 \
     ssh -N -R 127.0.0.1:${PORT}:127.0.0.1:22 ${USERNAME}@leia1"

# Ensure logs directory exists
if [[ ! -d ~/logs ]]; then
  echo -e "\n💻 Creating logs directory at ~/logs"
  mkdir -p ~/logs
fi

CMD0="ssh -t ${USERNAME}@skyriver.nri.bcm.edu \"${REMOTE_CMD}\""
echo -e "\n💻 Starting SSH job on any available node"
tmux new-window -t "$SESSION":1 -n win0 "bash -lc \"$CMD0 >~/logs/${SESSION}_win0.log 2>&1; exec bash\""

CMD1="ssh -N -L ${PORT}:127.0.0.1:${PORT} ${USERNAME}@skyriver.nri.bcm.edu"
tmux new-window -t "$SESSION":2 -n win1 "bash -lc \"$CMD1 >~/logs/${SESSION}_win1.log 2>&1; exec bash\""

# Remove the placeholder window so only your two windows remain
tmux kill-window -t "$SESSION":0 || true

echo -e "\n💻 Tunnel setup complete: Node:Port → Headnode:${PORT} → Your laptop"
echo -e "\n⏳ On http://skyriver.nri.bcm.edu:4200/#/status, wait until your job is RUNNING"
echo -e "\n💻 Open VS Code → SSH to host alias '${HOST_ALIAS}'"
echo -e "\n Okay Bye 👋 \n"
