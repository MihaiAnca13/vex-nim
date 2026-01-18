#!/bin/bash

# --- Configuration ---
MODEL_NAME="openbmb/minicpm-v4.5"
MODELS_PATH="/usr/share/ollama/.ollama/models"

# --- 1. Cleanup Function ---
# This ensures that if you Ctrl+C the script, the background server stops too.
cleanup() {
    echo -e "\nStopping Ollama server..."
    kill $OLLAMA_PID
    exit
}
trap cleanup SIGINT

# --- 2. Start Ollama Server in Background ---
echo "Starting Ollama with models from: $MODELS_PATH"
export OLLAMA_MODELS="$MODELS_PATH"
ollama serve &
OLLAMA_PID=$!

# --- 3. Wait for Server to be Ready ---
echo "Waiting for server to initialize..."
# Loops until the server responds to a ping
while ! curl -s http://localhost:11434 > /dev/null; do
    sleep 1
done
echo "Server is up!"

# --- 4. Preload the Model ---
echo "Preloading $MODEL_NAME into memory (indefinite keep-alive)..."
# We send an empty prompt just to load weights. keep_alive -1 keeps it loaded.
curl http://localhost:11434/api/generate -d "{
  \"model\": \"$MODEL_NAME\",
  \"keep_alive\": -1
}"

echo -e "\n\n>>> System Ready. Model is loaded. Press Ctrl+C to stop."

# --- 5. Keep Script Running ---
wait $OLLAMA_PID