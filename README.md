# Kaggle_VSCode_Remote_SSH

This repository provides an efficient setup for connecting to Kaggle notebooks via SSH using `ngrok`.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [SSH Setup](#ssh-setup)
   - [Step 1: Generate SSH Keys](#step-1-generate-ssh-keys)
   - [Step 2: Add SSH Public Key to GitHub](#step-2-add-ssh-public-key-to-github)
   - [Step 3: Get Ngrok Authtoken](#step-3-get-ngrok-authtoken)
3. [Using the SSH Setup on Kaggle](#using-the-ssh-setup-on-kaggle)
4. [Connect via SSH](#connect-via-ssh)
5. [Additional Information](#additional-information)
   - [Managing SSH Keys](#managing-ssh-keys)
   - [Troubleshooting](#troubleshooting)

## Prerequisites

- Kaggle Notebook
- Ngrok account
- A public repository containing your `authorized_keys` file

## SSH Setup

> [!WARNING]
>
> Due to recent Ngrok policy changes, using its services might be limited:
>
> - TCP endpoints are only available on a free plan after [adding a valid payment method](https://dashboard.ngrok.com/settings#id-verification) to your account.
> - **Data Transfer Limits**: Free account are limited to 1GB data transfer.
>
> Otherwise checkout [zrok branch](https://github.com/buidai123/Kaggle_VSCode_Remote_SSH/tree/feat/zrok-integration) (offers same features with less limits and does not require CC)
>
> ![image](https://github.com/user-attachments/assets/96b2c14a-dc22-46db-a8f0-7229380a6173)

### Step 1: Generate SSH Keys

1. Open your terminal.
2. Generate a new SSH key pair by running:

   ```sh
   ssh-keygen -t rsa -b 4096 -C "kaggle_remote_ssh" -f ~/.ssh/kaggle_rsa
   ```

3. Follow the prompts. Save the keys in the location ~/.ssh/kaggle_rsa

### Step 2: Add the SSH Public Key to GitHub

1. Locate your public key by running:

   ```sh
   cat ~/.ssh/kaggle_rsa.pub
   ```

2. Copy the contents of the public key.
3. Go to [GitHub](https://github.com) and log in.
4. Create a new GitHub repository (e.g., `SSH_public_key`).
5. In the repository, create a file name whatever you want, let's say `authorized_keys` and paste your SSH public key into this file.
6. Save and commit the file.
7. Click to `authorized_keys` file then click to `raw` then copy the url like this

<img src="images/github1.png">

### Step 3: Get Ngrok Authtoken

1. Go to [Ngrok](https://ngrok.com) and sign in or create an account.
2. Navigate to the "Authtoken" section of the dashboard.
3. Copy your auth token.

## Using the SSH Setup on Kaggle

- Create a Kaggle notebook, choose your desired GPU, adjust persistence if needed, enable internet access.

<img src="images/kaggle1.png" width="200" height="300">

- Run the following commands in a notebook cell:

```bash
!printenv > /kaggle/working/kaggle_env_vars.txt
!git clone https://github.com/buidai123/Kaggle_VSCode_Remote_SSH.git /kaggle/working/Kaggle_VSCode_Remote_SSH
%cd /kaggle/working/Kaggle_VSCode_Remote_SSH
!pip install -r requirements.txt
!chmod +x install_extensions.sh setup_kaggle_ssh.py setup_ssh.sh
!./setup_ssh.sh <your-public-key-link>
!python3 setup_kaggle_ssh.py <ngrok-auth-key>
```

- Wait until the setup is complete as shown in the image below.

<img src="images/kaggle2.png">

> [!NOTE]
> i use password here as the fallback if the ssh key doesn't work properly so if you're using Linux you can ignore this password

## Connect via SSH

- Install the required VSCode extensions.

<img src="images/vscode1.png">

- Hit `ctrl` + `shift` + `p`, search for `Remote-SSH: Connect to Host` and choose `Configure SSH Hosts`

<img src="images/vscode2.png">

- Select the first option or paste the path to your config file in the settings.

<img src="images/vscode3.png">

- Update your `~/.ssh/config` file on your local machine with the connection details:

```plaintext
Host "Kaggle"
    HostName <hostname from script output>
    User root
    Port <port from script output>
    IdentityFile <path to your private key>
```

<img src="images/vscode4.png">

- Save it and hit `ctrl` + `shift` + `p` again. Choose `Configure SSH Hosts`and select the host name you set earlier.

<img src="images/vscode5.png">

- A new window will appear; if prompted for the OS, choose Linux, then continue and enter your password if required. That's it!

- Note that the first time you connect if it said `could not connect...` then you need to empty your config file and this time choose `Add New SSH Host...` and paste this command in

```bash
ssh root@<HostName> -p <Port>
```

Replace `<HostName>` and `<Port>` like before

- After connected go to kaggle folder(you might want to work there). You can open terminal and run the following command to install necessary extension

```sh
    ./working/Kaggle_VSCode_Remote_SSH/install_extensions.sh
```

> [!TIP]
>
> <img src="images/thorium.png">
>
> If you're using chromium base browser you can disable battery saver mode for the Kaggle tab by going to `chrome://discards` click to toggle to to disable auto discardable

## Additional Information

### Managing SSH Keys

- **Multiple Keys**: Store each key pair in separate files and configure SSH clients to use the appropriate key.
- **Security**: Secure your private keys and distribute only public keys.

### Troubleshooting

> [!IMPORTANT]
>
> **Remember to add a CC to your Ngork account first**

- **Connectivity Issues**: Ensure that your Kaggle Notebook is running and that the ngrok tunnel is active.
- **Permission Denied**: Verify permissions and paths to your SSH keys and ensure the public key is authorized in the Kaggle Notebook.

If you have any questions or need further assistance, feel free to reach out:

- Email: [ss1280dzzz@gmail.com](mailto:ss1280dzzz@gmail.com)
