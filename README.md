# Kaggle_VSCode_Remote_SSH

> [!WARNING]
>
> WIP

## How zrok compare to ngrok?

| Feature                | zrok          | ngrok               |
| ---------------------- | ------------- | ------------------- |
| `Data Transfer`        | `5GB/DAY`     | 1GB/month           |
| **Open Source**        | Yes           | No                  |
| `Credit Card Required` | `No`          | Yes (for free plan) |
| Free Plan              | Yes           | Yes                 |
| Self-hosting           | Do your thing | Enterprise only     |

5GB of data transferring per **DAY** vs 1GB per _month_ ( **150x** daily data transfer quite impressive right?)

![image](https://github.com/user-attachments/assets/96b2c14a-dc22-46db-a8f0-7229380a6173)

As for now use this

```bash
!printenv > /kaggle/working/kaggle_env_vars.txt
!git clone -b feat/zrok-integration https://github.com/buidai123/Kaggle_VSCode_Remote_SSH.git /kaggle/working/Kaggle_VSCode_Remote_SSH
%cd /kaggle/working/Kaggle_VSCode_Remote_SSH
!chmod +x zrok_setup.sh
!chmod +x setup_ssh.sh
!./setup_ssh.sh <your_public_key_repo>
!./zrok_setup.sh
!zrok enable <your_zrok_token>
!sleep 5
!zrok share private --backend-mode tcpTunnel localhost:22
```

for zrok token go [here](https://myzrok.io/) and make your own account, you will find your zrok token here

> [!NOTE]
>
> remember to change your account to starter plan that way you can use NetFoundry's public zrok instance.

![image](https://github.com/user-attachments/assets/5692143f-617e-40a0-8700-aea87aac1e0d)

then you're good to go

After finishing running in the kaggle you will have little like token at the end, copy it

go [here](https://docs.zrok.io/docs/guides/install/) install zrok in your local machine

if you're using an Arch based distro zrok is available in AUR

```bash
yay -S zrok-bin
```

Now you got zrok installed in your system

run this

```bash
zrok access private <the_token_from_kaggle>
```

now you'll got a dashboard like the image i show above which is some thing like `127.0.0.1:9191 ...`

use

```bash
ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/kaggle_rsa -p <port(here mine is 9191)> root@127.0.0.1
```

the port seems like persist so you don't have to adjust it every time you create a new instance

alternative you can put this in the `config` file at ~/.ssh

```text

  Host Kaggle
    HostName 127.0.0.1
    UserKnownHostsFile /dev/null
    StrictHostKeyChecking no
    IdentityFile ~/.ssh/kaggle_rsa
    Port <port>
    User root
```

if you do so you can use this

```bash
ssh Kaggle
```

Finally, you might want to transfer files around between local and remote, in our case we can use `rsync` for this:

```bash
# from local to remote
rsync -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/kaggle_rsa -p 9191" <path_to_the_local_file> root@127.0.0.1:/kaggle/working
```

```bash
# from remote to local
rsync -e "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/kaggle_rsa -p 9191" root@127.0.0.1:<path_to_the_remote_file> <destination_path_in_local>
```

![rsync](https://github.com/user-attachments/assets/74387224-c54e-41c6-a8d0-9466a6c12315)
