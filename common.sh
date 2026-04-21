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

# Determine storage strategy for tilemaker processing
# Sets STORE_ARGS array — source scripts should use "${STORE_ARGS[@]}"
#
# Usage:
#   --memory    Force in-memory processing
#   --disk      Force disk-backed processing
#   (no flag)   Interactive prompt based on available RAM
detect_store_strategy() {
  local available_ram_gb
  available_ram_gb=$(awk '/MemAvailable/ {printf "%d", $2/1024/1024}' /proc/meminfo)
  echo "Available RAM: ${available_ram_gb}GB"

  STORE_ARGS=()

  # Check if caller passed --memory or --disk
  if [ "${STORE_MODE:-}" = "memory" ]; then
    echo "Forced in-memory processing via --memory flag"
    return
  elif [ "${STORE_MODE:-}" = "disk" ]; then
    echo "Forced disk-backed processing via --disk flag"
    mkdir -p "$WORK_DIR"
    STORE_ARGS=(--store "${PWD}/${WORK_DIR}")
    return
  fi

  # Interactive: prompt user
  if [ "$available_ram_gb" -ge 64 ]; then
    echo "You have enough RAM for in-memory processing (faster)."
    read -rp "Process in memory? [Y/n] " choice
    if [[ "$choice" =~ ^[Nn] ]]; then
      echo "Using disk-backed store at ${PWD}/${WORK_DIR}"
      mkdir -p "$WORK_DIR"
      STORE_ARGS=(--store "${PWD}/${WORK_DIR}")
    else
      echo "Processing entirely in memory"
    fi
  else
    echo "Insufficient RAM for in-memory processing (need ~64GB)."
    read -rp "Try in-memory anyway? [y/N] " choice
    if [[ "$choice" =~ ^[Yy] ]]; then
      echo "Processing in memory (may use swap)"
    else
      echo "Using disk-backed store at ${PWD}/${WORK_DIR}"
      mkdir -p "$WORK_DIR"
      STORE_ARGS=(--store "${PWD}/${WORK_DIR}")
    fi
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
