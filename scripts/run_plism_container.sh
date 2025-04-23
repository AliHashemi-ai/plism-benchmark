#!/bin/bash

# ==============================================================================
# Apptainer Job Launcher for Hydra Cluster (Interactive)
# Author: Ali Hashemi
# Description: Launches a flexible srun + Apptainer container session on Hydra
# ==============================================================================

# ------------------------
# === Configurable CLI arguments ===
# ------------------------

PARTITION=${1:-gpu-2h}                             # SLURM partition (e.g., gpu-2h, gpu-5h, gpu-7d)
GPUS=${2:-1}                                       # Number of GPUs
CPUS=${3:-4}                                       # Number of CPUs per task
MEMORY=${4:-32G}                                   # RAM (e.g., 16G, 64G)
TIME_LIMIT=${5:-2:00:00}                           # Time limit (HH:MM:SS)
CONSTRAINT=${6:-}                                  # GPU type (optional: 80gb, 3090, h100)
EXCLUDE_NODES=${7:-}                               # Nodes to exclude (comma-separated)
JOB_NAME=${8:-apptainer_job}                       # Job name
LOG_DIR=${9:-$HOME/logs}                           # SLURM log output directory
CONTAINER=${10:-$HOME/containers/plism/plism.sif}  # Apptainer .sif file
OVERLAY=${11:-$HOME/containers/plism/plism_overlay.img}  # Overlay image
PROJECT_PATH=${12:-$HOME/projects/plism-benchmark}       # Path to your project
CONTAINER_PROJECT_PATH="/app"                      # Mount location inside the container

mkdir -p "$LOG_DIR"

# ------------------------
# === Display configuration summary ===
# ------------------------

echo "=============================================================================="
echo " Launching Apptainer container interactively on Hydra"
echo "=============================================================================="
echo " Job name:            $JOB_NAME"
echo " Partition:           $PARTITION"
echo " GPUs:                $GPUS"
echo " CPUs per task:       $CPUS"
echo " Memory:              $MEMORY"
echo " Time limit:          $TIME_LIMIT"
echo " Constraint:          $CONSTRAINT"
echo " Exclude nodes:       $EXCLUDE_NODES"
echo " Container image:     $CONTAINER"
echo " Writable overlay:    $OVERLAY"
echo " Project path (host): $PROJECT_PATH"
echo " Project path (in container): $CONTAINER_PROJECT_PATH"
echo " Log directory:       $LOG_DIR"
echo " Email notifications: hashemi@tu-berlin.de"
echo "=============================================================================="

# ------------------------
# === Construct optional SLURM flags ===
# ------------------------

CONSTRAINT_FLAG=""
if [ -n "$CONSTRAINT" ]; then
  CONSTRAINT_FLAG="--constraint=$CONSTRAINT"
fi

EXCLUDE_FLAG=""
if [ -n "$EXCLUDE_NODES" ]; then
  EXCLUDE_FLAG="--exclude=$EXCLUDE_NODES"
fi

# ------------------------
# === Launch interactive job ===
# ------------------------

srun --partition="$PARTITION" \
     --gpus="$GPUS" \
     --cpus-per-task="$CPUS" \
     --mem="$MEMORY" \
     --time="$TIME_LIMIT" \
     --job-name="$JOB_NAME" \
     --output="$LOG_DIR/${JOB_NAME}-%j.out" \
     --exclusive \
     --mail-user=hashemi@tu-berlin.de \
     --mail-type=BEGIN,END,FAIL \
     $CONSTRAINT_FLAG \
     $EXCLUDE_FLAG \
     --pty \
     bash -c "
       echo '[INFO] Starting Apptainer container...'
       apptainer shell --nv \
         --overlay $OVERLAY \
         --bind $PROJECT_PATH:$CONTAINER_PROJECT_PATH \
         $CONTAINER
     "
