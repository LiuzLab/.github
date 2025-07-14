# Skyriver Orientation

---

# 🚀 Welcome to the Leia Slurm Cluster

Welcome! You now have access to our Slurm-based compute cluster. Here's a quick guide to get you productive fast.

---

## 🧭 1. Where You Are

Username and Password will be sent through

```bash
ssh <username>@skyriver.nri.bcm.edu

The authenticity of host 'x.x.x.x (x.x.x.x)' can't be established.
ECDSA key fingerprint is asdfasdfo80sad8f7a9sd0f7a89sdf0987asdfo87a6sdf.
Are you sure you want to continue connecting (yes/no/[fingerprint])?

type yes here

and then you will be asked for password 
<enter password> 

```

- You’re logging into the **head node**: `leia1`
- This node is for job submission
- Do **not** run heavy computation on the head node

---

## 💻 2. Auto Compute Shell Prompt

1. Termius ([quick start](https://www.techrepublic.com/article/how-to-use-termius-ssh/){:target="_blank"}) is good for quick SSH session 
2. VS-Code is awesome with both terminal and IDE 

When you SSH into the cluster or open a terminal:

```
Do you want to enter a compute shell? [Y/n]

```

- Press `Y` or hit Enter to start a Slurm interactive shell on a worker node
- Press `N` to stay on the head node for lightweight tasks (like file browsing)

---

## ⚙️ 3. Running Jobs

### ✅ Option A: **Interactive shell** (good for exploration & development)

```bash
srun --pty --job-name=devshell --time=01:00:00 bash

```

---

### ✅ Option B: **Batch job** (best for long-running or scripted jobs)

Create a file `job.slurm`:

```bash
#!/bin/bash
#SBATCH --job-name=myjob
#SBATCH --output=output.txt
#SBATCH --time=02:00:00
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

module load conda
conda activate aim
python my_script.py

```

Submit it:

```bash
sbatch job.slurm

```

---

### ✅ Option C: **Use a reservation** (for reserved time slots)

If a reservation has been made for you (use [skyriver.nri.bcm.edu:4200](http://skyriver.nri.bcm.edu:4200) for reserving a node when needed), launch like this:

**Interactive session with reservation:**

```bash
srun --pty --job-name=devres --time=01:00:00 --reservation=teamblock bash

```

**Batch job with reservation:**

Add to your `job.slurm`:

```bash
#SBATCH --reservation=teamblock

```

Then submit as usual:

```bash
sbatch job.slurm

```

💡 Check available reservations with:

```bash
scontrol show reservation

```

---

## 🧪 4. Monitor Jobs

```bash
squeue -u $USER     # Show your jobs
scancel <jobid>     # Cancel a job

```

Jobs from the auto-shell show up as `shlurm` by default.

---

## 🧰 5. Module System

To load software:

```bash
module avail
module load anaconda3/3.11

```

Use your own modulefiles:

```bash
module load use.own
module avail

```

---

## 📦 6. Conda Environments

Create and use your own:

```bash
conda create -n myenv python=3.9
conda activate myenv

```

---

## 🛑 7. What *Not* To Do

- Don’t run jobs directly on the head node
- Don’t leave idle compute shells open

---

## 🙋 Need Help?

Contact your cluster admin or run:

```bash
man srun
man sbatch

```

Or just ask in your internal support channel.

---
