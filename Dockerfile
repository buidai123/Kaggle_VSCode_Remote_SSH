FROM ubuntu:latest

# Build arguments for secrets
ARG AUTH_KEYS_URL_ARG
ARG ZROK_TOKEN_ARG

# Set environment variables from build arguments
ENV AUTH_KEYS_URL=$AUTH_KEYS_URL_ARG
ENV ZROK_TOKEN=$ZROK_TOKEN_ARG

# Avoid interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies your scripts need
RUN apt-get update && apt-get install -y \
    openssh-server \
    wget \
    curl \
    git \
    sudo \
    # Add any other dependencies your scripts might need (e.g., from zrok_setup.sh)
    && rm -rf /var/lib/apt/lists/*

# Create a dummy kaggle_env_vars.txt file as setup_ssh.sh expects it
RUN mkdir -p /kaggle/working && \
    echo "DUMMY_ENV_VAR=example_value" > /kaggle/working/kaggle_env_vars.txt

# Set up the working directory structure similar to Kaggle
WORKDIR /kaggle/working/Kaggle_VSCode_Remote_SSH

# Copy your project files into the container
COPY . .

# Make scripts executable
RUN chmod +x setup_ssh.sh zrok_setup.sh install_extensions.sh test_all.sh

# Expose SSH port (optional, for more advanced testing if you complete SSH setup)
# EXPOSE 22

# Default command (or you can override this when running the container)
CMD ["./test_all.sh"]
