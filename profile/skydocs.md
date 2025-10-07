

# 🪐 Skyriver Orientation

Welcome! You now have access to our Slurm-based compute cluster.

Here's a quick guide to get you productive fast. 

Cluster realtime usage and details available at : ([Skyriver page](http://skyriver.nri.bcm.edu:4200/#/nodes))

---

## 📍 1. You are here

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

* You’re logging into the **head node**: `leia1`
* This node is for job submission
* Do **not** run heavy computation on the head node

---

## 💻 2. Auto Compute Shell Prompt

1. Termius ([quick start](https://www.techrepublic.com/article/how-to-use-termius-ssh/)) is good for quick SSH session
2. VS Code is awesome with both terminal and IDE

When you SSH into the cluster or open a terminal:

```
Do you want to enter a compute shell? [Y/n]
```

* Press `Y` or hit **Enter** to start a Slurm interactive shell on a worker node
* Press `N` to stay on the head node for lightweight tasks (like file browsing)

---

## ⚙️ 3. Running Jobs

### ✅ Option A: **Interactive Shell** (good for exploration & development)

```bash
srun --pty --job-name=devshell --time=01:00:00 bash
```

> **Note:**
> If you don’t specify a partition, jobs will run in the **default queue (`defq15`)**.
> For GPU jobs, use `--partition=a30q` or `--partition=a100q`.
> For longer-running CPU jobs, use `--partition=defq610`.

---

### ✅ Option B: **Batch Job** (best for long-running or scripted jobs)

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
conda activate aim
python my_script.py
```

Submit it:

```bash
sbatch job.slurm
```

---

## 🧭 3.1. Understanding Queues

Different queues (also called **partitions**) are available for various workloads:

| Queue       | Description                        | Typical Usage                                              |
| ----------- | ---------------------------------- | ---------------------------------------------------------- |
| **defq15**  | Default queue for general CPU jobs | Standard analysis or short jobs (<15 hrs)                  |
| **defq610** | Long-duration CPU queue            | Multi-day runs or batch pipelines (>15 hrs)                |
| **a30q**    | GPU queue with NVIDIA A30 GPUs     | Moderate GPU workloads (e.g., model training, inference)   |
| **a100q**   | GPU queue with NVIDIA A100 GPUs    | High-performance GPU workloads (large-scale deep learning) |

## 3.2 Using Visual studio code and wsl

Please utilize this helper script ([skycode.sh](https://github.com/LiuzLab/.github/blob/main/profile/skycode.sh)) 

Windows users can run bash scripts using wsl : ([wsl usage](https://github.com/LiuzLab/.github/blob/main/profile/using_wsl.md))

---

### ✅ Example Job Submissions

#### **CPU Job (Default Queue)**

```bash
#!/bin/bash
#SBATCH --job-name=cpu_job
#SBATCH --output=cpu_output.txt
#SBATCH --partition=defq15
#SBATCH --time=04:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G

python my_script.py
```

#### **Long Job**

```bash
#SBATCH --partition=defq610
#SBATCH --time=72:00:00
```

#### **GPU Job (A30)**

```bash
#SBATCH --partition=a30q
#SBATCH --gres=gpu:1
#SBATCH --time=08:00:00
```

#### **GPU Job (A100)**

```bash
#SBATCH --partition=a100q
#SBATCH --gres=gpu:1
#SBATCH --time=04:00:00
```

---

### ✅ Option C: **Using Reservations (for dedicated time slots)**

If you need a dedicated reservation (for example, for teaching sessions, workshops, or large-scale coordinated runs), please **email the cluster admin** with the following details:

* Requested date and time window
* Duration of the reservation
* Number of nodes and resources needed
* Purpose or event name

🕐 **Please submit reservation requests at least one week prior** to your desired slot.
Reservations are approved on a case-by-case basis depending on cluster availability.

To check existing reservations:

```bash
scontrol show reservation
```

Once your reservation is confirmed, you can use it as follows:

**Interactive session with reservation:**

```bash
srun --pty --job-name=devres --time=01:00:00 --reservation=<reservation_name> bash
```

**Batch job with reservation:**

```bash
#SBATCH --reservation=<reservation_name>
```

Then submit as usual:

```bash
sbatch job.slurm
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

* Don’t run jobs directly on the head node
* Don’t leave idle compute shells open

---

## 🙋 Need Help?

Contact your cluster admin or run:

```bash
man srun
man sbatch
```

Or just ask in your internal support channel.

---

