## How to use Modules on Skyriver:

### \# Basic Module Commands

These are the commands you'll use most frequently to interact with the module system.

| Command | Description | Example |
| :--- | :--- | :--- |
| `module avail` | Lists all software modules available on the system. | `module avail` |
| `module avail <name>` | Searches for a specific module. | `module avail gcloud` |
| `module load <name>/<version>` | Loads a specific version of a software package into your environment. **(Recommended)** | `module load gcloud/540.0.0` |
| `module list` | Shows all the modules you currently have loaded. | `module list` |
| `module unload <name>` | Removes a module from your current environment. | `module unload gcloud` |
| `module purge` | Unloads **all** currently loaded modules. Useful for starting with a clean slate. | `module purge` |
| `module show <name>` | Displays information about a specific module, like what it does and any dependencies. | `module show anaconda3` |

-----



### Modules requiring extra work : (First-Time Setup)
Some modules require a one-time setup to integrate with your user account.

#### \# Anaconda3 (Conda)

Conda needs to initialize your shell to manage its environments properly.

1.  **Load the Anaconda module:**

    ```bash
    module load Anaconda3
    ```

2.  **Initialize Conda:**
    This command will modify your `.bashrc` file so `conda` is available every time you log in.

    ```bash
    conda init
    ```

3.  **Activate the changes:**
    You must either close and re-open your terminal session or run the following command:

    ```bash
    source ~/.bashrc
    ```

    You should now see `(base)` at the beginning of your command prompt, indicating that Conda is active.

#### \# Google Cloud SDK (gcloud)

You need to authenticate your account to use tools like `gcloud`, `bq`, and `gsutil`.

1.  **Load the Google Cloud module:**

    ```bash
    module load gcloud/540.0.0
    ```

2.  **Initialize the SDK:**
    This will start the authentication process.

    ```bash
    gcloud init
    ```

3.  **Follow the on-screen prompts:**

      * You'll be asked to log in to your Google account in a web browser.
      * After logging in, you'll be prompted to grant permissions to the Google Cloud SDK.
      * A verification code will be provided in your browser; copy and paste this code back into your terminal.
      * Finally, select your desired GCP project from the list provided.

4.  **Verify your setup:**
    Run these commands to ensure everything is working correctly.

    ```bash
    gcloud version
    bq version
    gsutil version
    ```

    > **💡 Tip:** If you need to switch to a different GCP project later, you don't need to run `gcloud init` again. Just use: `gcloud config set project <your-other-project-id>`
