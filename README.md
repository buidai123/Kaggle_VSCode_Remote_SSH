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

# Or even simpler:
!zrok enable <your_zrok_token>
!sleep 5
!zrok share private --backend-mode tcpTunnel localhost:22
```

for zrok token go [here](https://myzrok.io/) and make your own account find your zrok token here

> [!NOTE]
>
> remember to change your account to starter plan that way you can NetFoundry's public zrok instance.

![image](https://github.com/user-attachments/assets/5692143f-617e-40a0-8700-aea87aac1e0d)

then you're good to go
