#!/bin/bash

# ==============================================================================
# Apptainer Jupyter Notebook Launcher for Hydra Cluster (Interactive)
# Author: Ali Hashemi
# Description: Launches Jupyter inside an Apptainer container via srun with SSH tunneling
# ==============================================================================

# ------------------------
# === Configurable CLI arguments ===
# ------------------------

PARTITION=${1:-gpu-2h}                                       # SLURM partition
GPUS=${2:-1}                                                 # Number of GPUs
CPUS=${3:-4}                                                 # CPU cores per task
MEMORY=${4:-32G}                                             # Memory allocation
TIME_LIMIT=${5:-2:00:00}                                     # Job time limit
CONSTRAINT=${6:-}                                            # GPU type constraint (optional)
EXCLUDE_NODES=${7:-}                                         # Nodes to exclude (optional)
JOB_NAME=${8:-jupyter_apptainer}                             # SLURM job name
LOG_DIR=${9:-$HOME/logs}                                     # Directory for job logs
CONTAINER=${10:-$HOME/containers/plism/plism.sif}            # Apptainer container
OVERLAY=${11:-$HOME/containers/plism/plism_overlay.img}      # Writable overlay
PROJECT_PATH=${12:-$HOME/projects/plism-benchmark}           # Host project path
CONTAINER_PROJECT_PATH="/app"                                # Mount point inside container
JUPYTER_PORT=8888                                            # Port to use for Jupyter

mkdir -p "$LOG_DIR"

# ------------------------
# === Display configuration summary ===
# ------------------------

echo "=============================================================================="
echo " Launching Jupyter Notebook inside Apptainer on Hydra"
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
echo " Mount inside:        $CONTAINER_PROJECT_PATH"
echo " Jupyter port:        $JUPYTER_PORT"
echo " Log directory:       $LOG_DIR"
echo "=============================================================================="

# ------------------------
# === Optional SLURM flags ===
# ------------------------

CONSTRAINT_FLAG=""
[ -n "$CONSTRAINT" ] && CONSTRAINT_FLAG="--constraint=$CONSTRAINT"

EXCLUDE_FLAG=""
[ -n "$EXCLUDE_NODES" ] && EXCLUDE_FLAG="--exclude=$EXCLUDE_NODES"

# ------------------------
# === Launch the Jupyter job ===
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
       HOSTNAME=\$(hostname)
       echo '[INFO] Hostname: '\$HOSTNAME
       echo '[INFO] SSH tunnel command (on your local machine):'
       echo 'ssh -L 8888:'\$HOSTNAME':8888 hashemi@hydra.ml.tu-berlin.de -N'
       echo
       echo '[INFO] Launching Apptainer container with Jupyter Notebook...'
       apptainer exec --nv \
         --overlay $OVERLAY \
         --bind $PROJECT_PATH:$CONTAINER_PROJECT_PATH \
         $CONTAINER \
         jupyter notebook \
           --ip=0.0.0.0 \
           --port=$JUPYTER_PORT \
           --no-browser \
           --NotebookApp.password='' \
           --NotebookApp.token='' \
           --notebook-dir=$CONTAINER_PROJECT_PATH
     "
