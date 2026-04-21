#!/usr/bin/env bash
# shellcheck disable=SC2034
# Shared logic for all tilemaker processing workflows
# Variables defined here are used by scripts that source this file

# Directory layout
OUTPUT_DIR="output"
DOWNLOAD_DIR="downloads"
WORK_DIR="work"

mkdir -p "$OUTPUT_DIR" "$DOWNLOAD_DIR"

# Ensure all geodata required by config.json is present
ensure_geodata() {
  echo "Ensuring geodata is available..."
  ./get_data.sh
}

# Detect available RAM and set tilemaker store args accordingly
# Sets STORE_ARGS array — source scripts should use "${STORE_ARGS[@]}"
detect_store_strategy() {
  local available_ram_gb
  available_ram_gb=$(awk '/MemAvailable/ {printf "%d", $2/1024/1024}' /proc/meminfo)
  echo "Available RAM: ${available_ram_gb}GB"

  STORE_ARGS=()
  if [ "$available_ram_gb" -lt 64 ]; then
    echo "Using disk-backed store at ${PWD}/${WORK_DIR} (need ~64GB for in-memory, have ${available_ram_gb}GB)"
    mkdir -p "$WORK_DIR"
    STORE_ARGS=(--store "${PWD}/${WORK_DIR}")
  else
    echo "Sufficient RAM — processing entirely in memory"
  fi
}

# Common tilemaker flags for performance
TILEMAKER_COMMON_ARGS=(
  --config config.json
  --process process.lua
  --fast
  --no-compress-ways
  --no-compress-nodes
)
