IMAGE_NAME := kaggle-automated-test

# example in fish shell:
# set -x AUTH_KEYS_URL "your_url"
# set -x ZROK_TOKEN "your_token"
AUTH_KEYS_URL_ARG := $(AUTH_KEYS_URL)
ZROK_TOKEN_ARG := $(ZROK_TOKEN)

.PHONY: test clean

test:
	@echo "Building Docker image $(IMAGE_NAME)..."
	@if [ -z "$(AUTH_KEYS_URL_ARG)" ]; then \
		echo "Error: AUTH_KEYS_URL is not set in your environment."; \
		exit 1; \
	fi
	@if [ -z "$(ZROK_TOKEN_ARG)" ]; then \
		echo "Error: ZROK_TOKEN is not set in your environment."; \
		exit 1; \
	fi
	docker build --build-arg AUTH_KEYS_URL_ARG="$(AUTH_KEYS_URL_ARG)" \
	             --build-arg ZROK_TOKEN_ARG="$(ZROK_TOKEN_ARG)" \
	             -t $(IMAGE_NAME) .
	@echo "Running Docker container $(IMAGE_NAME)..."
	docker run --rm $(IMAGE_NAME)

clean:
	@echo "Removing Docker image $(IMAGE_NAME)..."
	@docker rmi $(IMAGE_NAME) || true

help:
	@echo "Available targets:"
	@echo "  test         - Builds the Docker image and runs the automated tests."
	@echo "  clean        - Removes the Docker image built by the 'test' target."
	@echo "  help         - Shows this help message."
	@echo ""
	@echo "Before running 'make test', ensure AUTH_KEYS_URL and ZROK_TOKEN are set in your shell environment."
	@echo "Example for fish shell:"
	@echo "  set -x AUTH_KEYS_URL \"your_authorized_keys_url\""
	@echo "  set -x ZROK_TOKEN \"your_zrok_token\""
