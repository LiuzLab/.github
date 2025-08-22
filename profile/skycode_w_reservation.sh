#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Script: launch_cs_tunnel.sh
#
# Purpose:
#   - Start a Slurm‐backed code‐server tunnel via screen:
#       1. Allocates your reserved worker node.
#       2. Opens a reverse SSH tunnel (worker → head node).
#       3. Opens a local SSH forward (head node → your laptop).
#       4. Wraps both in a detached GNU screen session.
#   - Teardown mode (“stop”): kills the screen session and any stray SSH tunnels.
#
# Prerequisites:
#   • SSH key access to skyriver.nri.bcm.edu (“head node”).
#   • GNU screen installed on your laptop.
#
# Usage:
#   # Start mode (launch tunnel):
#   ./launch_cs_tunnel.sh \
#      -u USER           # cluster username
#      -r RESERVATION    # Slurm reservation name
#      -n NODENAME       # target worker node
#      -q PARTITION      # Slurm partition/queue
#      -p PORT           # tunnel port (e.g. 20527)
#
#   # Stop mode (teardown tunnel):
#   ./launch_cs_tunnel.sh -s [-p PORT]
#
# Examples:
#   # start
#   ./launch_cs_tunnel.sh -u sasidharp -r sasidharp_979 \
#     -n droidnode004 -q defq15 -p 20527
#
#   # stop (also kills ssh processes on port 20527)
#   ./launch_cs_tunnel.sh -s -p 20527
###############################################################################

SESSION_PREFIX="skycode"

usage() {
  cat <<EOF
Usage:
  $0 -s [-p PORT]        # only stop mode, optional -p to cleanup tunnels
  $0 -u USER -r RES -n NODE -q PART -p PORT   # start mode

Options:
  -s               stop: kill existing screen sessions (and tunnels if -p given)
  -u USER          your cluster username
  -r RES           Slurm reservation name
  -n NODE          target worker node
  -q PART          Slurm partition
  -p PORT          tunnel port (required in start mode; optional in stop mode)
EOF
  exit 1
}

# defaults
STOP=false
PORT=


while getopts "su:r:n:q:p:" opt; do
  case $opt in
    s) STOP=true ;;
    u) USERNAME=$OPTARG ;;
    r) RESERVATION=$OPTARG ;;
    n) NODENAME=$OPTARG ;;
    q) PARTITION=$OPTARG ;;
    p) PORT=$OPTARG ;;
    *) usage ;;
  esac
done


# If stop mode, do cleanup and exit
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

# Otherwise, start mode: require all start args
[[ -n "${USERNAME-}" && -n "${RESERVATION-}" && -n "${NODENAME-}" && -n "${PARTITION-}" && -n "${PORT-}" ]] || usage

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

SESSION="skycode_${NODENAME}_skycode"

# 2) start a detached screen session
echo -e "\n💻 Starting screen session '${SESSION}'"
screen -dmS "$SESSION"

# 3) window 0: run the Slurm + reverse-tunnel on the head node
REMOTE_CMD="source /etc/profile && module load slurm && \
srun --pty --reservation=${RESERVATION} \
     --job-name=sky-${USERNAME} \
     --nodes=1 --ntasks=1 --nodelist=${NODENAME} \
     --partition=${PARTITION} \
     ssh -N -R 127.0.0.1:${PORT}:127.0.0.1:22 ${USERNAME}@leia1"

CMD0="ssh -t ${USERNAME}@skyriver.nri.bcm.edu \"${REMOTE_CMD}\""

echo -e "\n💻 Starting SSH job on worker node"

# echo "   screen -S ${SESSION} -X screen bash -c \"${CMD0}; exec bash\""
screen -S "$SESSION" -X screen bash -c "$CMD0; exec bash"

echo -e "\n💻 Setting tunnel from ${NODENAME}:22 → Headnode:${PORT}"

# 4) window 1: run the local forward to head node
CMD1="ssh -N -L ${PORT}:127.0.0.1:${PORT} ${USERNAME}@skyriver.nri.bcm.edu"


# echo "   screen -S ${SESSION} -X screen bash -c \"${CMD1}; exec bash\""
screen -S "$SESSION" -X screen bash -c "$CMD1; exec bash"
echo -e "\n💻 Setting tunnel from Head node ${PORT} → 💻 Your computer ${PORT}"
echo -e "\n⏳ On http://skyriver.nri.bcm.edu:4200/#/status wait till your job vskycode-${RESERVATION} is running"
echo -e "\n💻 Open VS Code → under SSH hosts use ${HOST_ALIAS} to open your coding session"
echo -e "\n Okay Bye 👋 \n"

