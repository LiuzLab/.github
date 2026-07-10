# 🪐 Skyriver Orientation

Welcome! You now have access to our Slurm-based compute cluster.
Here's a quick guide to get you productive fast.

Cluster realtime usage and details available at: [Skyriver page](http://skyriver.nri.bcm.edu:4200/#/nodes)

---

## 📍 1. You are here

Username and password will be sent to you separately.

```bash
ssh <username>@skyriver.nri.bcm.edu
```

When prompted about the host fingerprint, type `yes`, then enter your password.

- You're logging into the **head node**: `leia1`
- This node is for job submission and light file management only
- **Do not run heavy computation on the head node**

---

## 💻 2. Auto Compute Shell Prompt

[Termius](https://www.techrepublic.com/article/how-to-use-termius-ssh/) is good for quick SSH sessions. VS Code works great with both terminal and IDE support.

When you SSH into the cluster or open a terminal:

```
Do you want to enter a compute shell? [Y/n]
```

- Press `Y` or hit **Enter** to start a Slurm interactive shell on a worker node (droidnode001 or droidnode002)
- Press `N` to stay on the head node for lightweight tasks like file browsing

> **Note:** You will not be able to create an `srun` session through the auto compute shell. If you plan to use `srun`, press `N` and stay on the head node.

---

## ⚙️ 3. Running Jobs

### Option A: Interactive shell (good for exploration and development)

```bash
srun --pty --job-name=devshell --time=01:00:00 bash
```

> If you don't specify a partition, jobs run in the default queue (`defq15`).
> For GPU jobs use `--partition=a30q` or `--partition=a100q`.
> For longer-running CPU jobs use `--partition=defq610`.

---

### Option B: Batch job (best for long-running or scripted jobs)

Create a file `job.slurm`:

```bash
#!/bin/bash
#SBATCH --job-name=myjob
#SBATCH --output=output.txt
#SBATCH --partition=defq15
#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

module load conda
conda activate myenv
python my_script.py
```

Submit it:

```bash
sbatch job.slurm
```

---

## 🧭 3.1. Understanding Partitions

Different partitions are available for different workloads. Choose the right one — it affects how quickly your job is scheduled and whether it will hit the time limit.

| Partition | Nodes | CPUs/node | RAM/node | Time limit | Best for |
|---|---|---|---|---|---|
| `debugq` | droidnode001-002 | 48 | 230GB | 8 hours | Testing and debugging scripts before a full run |
| `defq15` | droidnode003-005 | 48 | 230GB | 4 days | Standard CPU jobs expected to finish within 4 days |
| `defq610` | droidnode006-010 | 48 | 230GB | 7 days | Long-running CPU jobs that need more than 4 days |
| `a30q` | sabercore-a30-001 to 004 | 32 | 470GB | 7 days | GPU jobs (A30) and memory-heavy jobs (>230GB RAM) |
| `a100q` | sabercore-a100-001 to 003 | 32 | 470GB | 7 days | High-performance GPU jobs (A100) |

**Total cluster resources:**
- 8 CPU compute nodes — 384 CPUs, ~1.8TB RAM
- 7 GPU nodes — 224 CPUs, ~3.3TB RAM, 7 GPUs
- 2 login/debug nodes (droidnode001-002) — not for heavy computation

> **Not sure which partition to use?** Run a small test on `debugq` first, check the runtime with `sacct -j <jobid> --format=JobID,Elapsed`, then submit the full run to the appropriate partition.

---

## 📋 3.2. Example Job Scripts

### CPU job — short (defq15)

```bash
#!/bin/bash
#SBATCH --job-name=cpu_short
#SBATCH --partition=defq15
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=output_%j.txt

python my_script.py
```

### CPU job — long (defq610)

```bash
#!/bin/bash
#SBATCH --job-name=cpu_long
#SBATCH --partition=defq610
#SBATCH --time=5-00:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --output=output_%j.txt

python my_script.py
```

### GPU job — A30

```bash
#!/bin/bash
#SBATCH --job-name=gpu_a30
#SBATCH --partition=a30q
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --gres=gpu:1
#SBATCH --output=output_%j.txt

python train.py
```

### GPU job — A100

```bash
#!/bin/bash
#SBATCH --job-name=gpu_a100
#SBATCH --partition=a100q
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --gres=gpu:1
#SBATCH --output=output_%j.txt

python train.py
```

### Memory-heavy job (>230GB RAM, no GPU)

```bash
#!/bin/bash
#SBATCH --job-name=highmem
#SBATCH --partition=a30q
#SBATCH --qos=highmem_qos
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=400G
#SBATCH --output=output_%j.txt

python memory_intensive.py
```

---

## 3.3. Using Visual Studio Code and WSL

Use the helper script [skycode.sh](https://github.com/LiuzLab/.github/blob/main/profile/skycode.sh) to connect VS Code to the cluster.

Windows users can run bash scripts using WSL: [WSL usage guide](https://github.com/LiuzLab/.github/blob/main/profile/using_wsl.md)

---

### Option C: Reservations (for dedicated time slots)

If you need a dedicated reservation for teaching, workshops, or large coordinated runs, email the cluster admin with:

- Requested date and time window
- Duration
- Number of nodes and resources needed
- Purpose or event name

Please submit reservation requests **at least one week in advance**.

```bash
# Check existing reservations
scontrol show reservation

# Interactive session with reservation
srun --pty --job-name=devres --time=01:00:00 --reservation=<reservation_name> bash

# Batch job with reservation
#SBATCH --reservation=<reservation_name>
```

---

## 🧪 4. Monitor Jobs

```bash
squeue -u $USER         # Show your jobs
scancel <jobid>         # Cancel a job
sacct -j <jobid> --format=JobID,ReqCPUS,AllocCPUS,ReqMem,MaxRSS,Elapsed   # Check completed job usage
sshare -u $USER -l      # Check your fairshare score
```

Jobs from the auto-shell show up as `shlurm` by default.

---

## 🧰 5. Module System

```bash
module avail                    # List available modules
module load anaconda3/3.11      # Load a module
module load use.own             # Use your own modulefiles
```

---

## 📦 6. Conda Environments

```bash
conda create -n myenv python=3.9
conda activate myenv
```

---

## ⚖️ 7. Fair Use Policy & Resource Limits

This is a shared cluster. To ensure fair access for everyone, resource limits are enforced automatically based on your account. You don't need to configure anything — limits apply to your jobs by default.

Jobs that exceed your limits will queue — they won't be cancelled, just held until resources free up.

---

### Resource usage policy based limits

The limits below apply to your account. They are designed to prevent any single user from occupying the entire cluster while still giving you enough headroom for large workloads.

| Limit | Value | Node equivalent | What happens when hit |
|---|---|---|---|
| Your CPUs at once | 144 | 3 droidnodes | Your new jobs queue — other users unaffected |
| Your memory at once | 690GB | 3 droidnodes | Your new jobs queue |
| CPUs per single job | 48 | 1 droidnode | Job rejected at submission — reduce `--cpus-per-task` |
| Memory per single job | 230GB | 1 droidnode | Job rejected at submission — reduce `--mem` |
| Running jobs at once | 75 | — | New jobs queue until one finishes |
| Jobs in queue at once | 200 | — | Submission rejected — remove pending jobs first |

> These limits apply automatically. You don't need to add any QOS flag to your job script for standard CPU jobs.

---

### GPU limits (all users)

Required for all jobs on `a30q` and `a100q`. Jobs submitted to GPU partitions without `--gres=gpu` will be rejected — GPU nodes are not available for CPU-only workloads.

| Limit | Value | What happens when hit |
|---|---|---|
| Your GPUs at once | 2 | Your GPU jobs queue |
| GPUs per single job | 2 | Job rejected at submission |
| Your CPUs at once (GPU nodes) | 64 | Your GPU jobs queue |
| Memory per single job (GPU nodes) | 470GB | Job rejected at submission |
| Running GPU jobs at once | 5 | New GPU jobs queue |
| GPU jobs in queue at once | 20 | Submission rejected |

```bash
# GPU job — must include --gres=gpu
#SBATCH --partition=a100q
#SBATCH --gres=gpu:1
```

---

### Memory-heavy jobs (highmem_qos)

If your job needs more than 230GB RAM but does not use a GPU, submit to `a30q` with `highmem_qos`. These nodes have 470GB usable RAM each.

| Limit | Value | What happens when hit |
|---|---|---|
| Your CPUs at once | 64 | Your jobs queue |
| Your memory at once | 1,500GB | Your jobs queue |
| CPUs per single job | 32 | Job rejected at submission |
| Memory per single job | 470GB | Job rejected at submission |
| Running jobs at once | 10 | New jobs queue |

```bash
#SBATCH --partition=a30q
#SBATCH --qos=highmem_qos
#SBATCH --mem=400G
#SBATCH --cpus-per-task=16
# Note: no --gres=gpu needed
```

---

### Which QOS should I use?

```
What kind of job are you running?
│
├── CPU job, finishes under 4 days
│   └── --partition=defq15
│       (limits applied automatically)
│
├── CPU job, needs more than 4 days
│   └── --partition=defq610
│       (limits applied automatically)
│
├── GPU job
│   └── --partition=a100q or a30q
│       --gres=gpu:1
│       (GPU limits applied automatically)
│
├── Memory-heavy job (>230GB RAM, no GPU)
│   └── --partition=a30q
│       --qos=highmem_qos
│       (only case where you need to specify a QOS)
│
└── Need more than your standard limits?
    └── Contact admins to request temporary burst access
```

---

### Understanding your job status

```bash
squeue -u $USER
```

If your job shows `PD` (pending), check the `REASON` column:

| Reason | Meaning | Action needed |
|---|---|---|
| `QOSMaxCpuPerUserLimit` | You hit your personal CPU cap | Wait for your running jobs to finish |
| `QOSMaxMemPerUserLimit` | You hit your personal memory cap | Wait or reduce `--mem` on pending jobs |
| `QOSGrpCpuLimit` | Your group hit the combined CPU cap | Wait for group members' jobs to finish |
| `QOSGrpMemLimit` | Your group hit the combined memory cap | Wait for group members to free up memory |
| `QOSMaxJobsPerUserLimit` | You hit your running jobs limit | Wait for a job to finish |
| `QOSSubmitJobLimit` | You hit your queue limit | Remove some pending jobs |
| `QOSMaxGRESPerUser` | You hit your GPU cap | Wait for a GPU job to finish |
| `Priority` | Resources available but others are ahead | Normal — job will start automatically |
| `Resources` | Waiting for nodes to free up | Normal — job will start automatically |

> `Priority` and `Resources` are completely normal — no action needed. Only `QOS*` reasons mean a limit has been hit.

---

### Tips for good cluster citizenship

**Right-size your resource requests.** Requesting more CPUs or memory than your job actually needs blocks other users and slows down your own queue time. Check your past job usage:

```bash
sacct -j <jobid> --format=JobID,ReqCPUS,AllocCPUS,ReqMem,MaxRSS,Elapsed
```

**Set a realistic time limit.** Jobs with shorter requested runtimes are scheduled faster by Slurm's backfill scheduler. If your job reliably finishes in 12 hours, don't request 4 days.

**Use the right partition.** Use `debugq` for testing — short 8-hour limit but jobs start faster. Use `defq15` for standard runs and `defq610` for anything that genuinely needs more than 4 days.

**Split large job arrays by input type.** If your array processes both small and large inputs, consider two separate arrays with different time limits and resource requests. This improves throughput for everyone.

---

### Requesting temporary burst access

If you have a legitimate need to exceed your standard limits — a paper deadline, an unusually large dataset, a one-time analysis — contact the admins. Temporary burst access can be granted on a case-by-case basis.

Please include in your request:
- How many CPUs, memory, or GPUs you need
- How long you need the extra resources
- What you are running and why standard limits are not sufficient

> **Note:** Burst jobs run at lower priority than standard jobs and may be automatically requeued if the cluster becomes busy. If your workflow supports checkpointing, enable it before using burst access.

---

## 🛑 8. What Not To Do

- Don't run jobs directly on the head node
- Don't leave idle compute shells open
- Don't request more CPUs or memory than your job actually needs
- Don't submit CPU-only jobs to GPU partitions (`a30q`, `a100q`)
- Don't set `--time` to the maximum just to be safe — it delays your job's scheduling

---

## 🙋 Need Help?

Contact your cluster admin or check:

```bash
man srun
man sbatch
man sacct
```

Or ask in your internal support channel.

---

*Policy last updated: June 2026*
