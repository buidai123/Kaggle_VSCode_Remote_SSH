FROM ubuntu:latest

ARG AUTH_KEYS_URL_ARG
ARG ZROK_TOKEN_ARG

ENV AUTH_KEYS_URL=$AUTH_KEYS_URL_ARG
ENV ZROK_TOKEN=$ZROK_TOKEN_ARG
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    openssh-server \
    wget \
    curl \
    git \
    sudo \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /kaggle/working && \
    echo "DUMMY_ENV_VAR=example_value" > /kaggle/working/kaggle_env_vars.txt

RUN mkdir -p /tmp/Kaggle_VSCode_Remote_SSH
COPY . /tmp/Kaggle_VSCode_Remote_SSH

WORKDIR /tmp/Kaggle_VSCode_Remote_SSH

# make scripts executable
RUN chmod +x setup_kaggle_zrok.sh install_extensions.sh test_all.sh

CMD ["./test_all.sh"]
# CMD ["bash"]
