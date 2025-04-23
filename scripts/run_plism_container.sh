#!/bin/bash

# ------------------------
# User-configurable options
# ------------------------

# Partition to request (e.g., gpu-2h, gpu-5h)
PARTITION=${1:-gpu-2h}

# Number of GPUs to request
GPUS=${2:-1}

# Apptainer image
CONTAINER=${3:-~/containers/plism/plism.sif}

# Writable overlay image
OVERLAY=${4:-~/containers/plism/plism_overlay.img}

# Path to your PLISM benchmark project
PROJECT_PATH=${5:-~/projects/plism-benchmark}

# ------------------------
# Start compute node session and enter container
# ------------------------

echo "Requesting node from partition: $PARTITION with $GPUS GPU(s)"
echo "Container: $CONTAINER"
echo "Overlay: $OVERLAY"
echo "Mounting project: $PROJECT_PATH"

srun --partition="$PARTITION" \
     --gpus="$GPUS" \
     --mem=32G \
     --cpus-per-task=4 \
     --time=2:00:00 \
     --pty \
     bash -c "
       apptainer shell --nv \
         --overlay $OVERLAY \
         --bind $PROJECT_PATH:/app \
         $CONTAINER
     "
