# Running ollama on cluster

Below is a **quick-start** guide to running Ollama on an HPC node using Singularity. It walks you through:

1. **Reserving a node** (so you have dedicated resources).
2. **Loading Singularity** and pulling a desired model (optional step if the model isn’t already in place).
3. **Creating a Slurm job script** to run the Ollama server.
4. **Creating another example job** to interact with the running Ollama server on the same node.

---

## 1. Reserve an HPC Node

Go to [skyriver.nri.bcm.edu:4200](http://skyriver.nri.bcm.edu:4200) and reserve a desired node in Reservations page

```bash
srun --reservation=<reservation_name> --partition=<name_of_queue> --nodeslist=<name_of_node> --time=1:00:00 --pty bash

```

---

## 2. Load Singularity and Pull a Model (Optional)

Once on the node (or from a login node, if allowed), load the Singularity module:

```bash
module load singularity

```

If you need to **pull** a specific Ollama model or Singularity image, do so now. For instance, you might already have:

```bash
singularity pull <model_location>

example : singularity pull docker://ollama/ollama:latest

```

*(If your Ollama image or model is already on the system, skip this step.)*

---

## 3. Create a Slurm Script to Serve Ollama

Use a text editor (e.g., `nano serve_ollama.sh`) and add the following content:

```bash
#!/bin/bash
#SBATCH --job-name=serve
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --time=02:00:00
#SBATCH --partition=<name_of_queue eg: a100q>
#SBATCH --output=ollama_serve_%j.log
#SBATCH --nodelist=<node_name>
#SBATCH --reservation=<reservation_name>

# Load necessary modules
module load singularity

# Define the path to your Singularity image
SINGULARITY_IMAGE=<location/of/ollama/sif>

# Start Ollama server on port 11434, listening on all interfaces
singularity exec --nv \
  --env OLLAMA_HOST=0.0.0.0 \
  --env OLLAMA_PORT=11434 \
  $SINGULARITY_IMAGE ollama serve

```

- Adjust `#SBATCH` lines (partition, node name, reservation, time, etc.) as needed for your cluster.
- Make sure the path in `SINGULARITY_IMAGE` points to the Ollama `.sif` file.

Submit this script:

```bash
sbatch serve_ollama.sh

```

When it starts, Ollama will listen on port **11434**. The job will keep running until the time expires (2 hours, as requested) or you cancel it.

> Important: As written, the script ends immediately after starting Ollama, which may terminate Ollama. If you want to keep Ollama running the entire time, add a sleep 2h (or sleep $((2 * 3600))) after launching the server, so Slurm doesn’t kill the background process. For example:
> 
> 
> ```bash
> singularity exec --nv ... ollama serve &
> sleep 2h
> 
> ```
> 

---

## 4. Create Another Job to Interact with Ollama Server

If you want a separate Slurm job/script to **send requests** to Ollama, ensure it runs on **the same node** during the same time window. For example, create `query_ollama.sh`:

```bash
#!/bin/bash
#SBATCH --job-name=query
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=1
#SBATCH --mem=2G
#SBATCH --time=00:30:00
#SBATCH --partition=a100q
#SBATCH --output=ollama_query_%j.log
#SBATCH --nodelist=<node_name>
#SBATCH --reservation=<reservation_name>

module load singularity

# Example of making a completion request via curl (assuming the server is running on this node, port 11434)
curl -X POST -H "Content-Type: application/json" -d '{
  "model": "llama2-7b.ggmlv3.q2_K.bin",
  "prompt": "Hello, how are you?"
}' http://localhost:11434/v1/completions

```

- Submit it **while** the first job is still running:
    
    ```bash
    sbatch query_ollama.sh
    
    ```
    
- Because both scripts specify the **same node** (`-nodelist=<node_name>`) and **reservation**, Slurm will try to schedule them on that node.
- Check your cluster’s policy: some HPCs do **not** allow multiple concurrent jobs on the same node. If that’s the case, you might need a single script that starts Ollama in the background and then runs queries.

---

### **Verifying**

- **Check `squeue -u <username>`** to see if both jobs are running.
- **Look in the log files** (`ollama_serve_<jobID>.log` and `ollama_query_<jobID>.log`) to see any output.
- If you need interactive access to do `curl localhost:11434`, you can `ssh` or `srun` into the same node **while** the server job is running (depending on cluster policies).

---

## **That’s It!**

1. **Reserve a node** or submit a job to run Ollama.
2. **Load Singularity**, optionally pull the model you want.
3. **Run Ollama** via a Slurm job script that starts the server.
4. **Use another job** (or interactive shell on the same node) to interact with Ollama’s API on port 11434.

Feel free to customize the scripts based on your HPC environment (time limits, memory, node reservations, etc.). Enjoy running your LLM workloads on the cluster!
