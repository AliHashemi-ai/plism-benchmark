#!/bin/bash

#SBATCH --job-name=jupyter_apptainer
#SBATCH --partition=gpu-2h
#SBATCH --gpus=1
#SBATCH --cpus-per-task=2
#SBATCH --mem=16G
#SBATCH --time=2:00:00
#SBATCH --output=$HOME/logs/jupyter_apptainer-%j.out
#SBATCH --mail-user=hashemi@tu-berlin.de
#SBATCH --mail-type=BEGIN,END,FAIL
# Optional constraints (uncomment if needed)
## #SBATCH --constraint=80gb
## #SBATCH --exclude=head021,head022

# ------------------------
# === Runtime paths and settings ===
# ------------------------

CONTAINER="$HOME/containers/plism/plism.sif"
OVERLAY="$HOME/containers/plism/plism_overlay.img"
PROJECT_PATH="$HOME/projects/plism-benchmark"
CONTAINER_PROJECT_PATH="/app"
JUPYTER_PORT=8888

echo "=============================================================================="
echo " Starting batch job: Jupyter Notebook inside Apptainer"
echo "=============================================================================="
echo " Hostname: $(hostname)"
echo " Jupyter port: $JUPYTER_PORT"
echo " Tunnel with:"
echo "ssh -L 8888:$(hostname):8888 hashemi@hydra.ml.tu-berlin.de -N"
echo "=============================================================================="

apptainer exec --nv \
  --overlay "$OVERLAY" \
  --bind "$PROJECT_PATH:$CONTAINER_PROJECT_PATH" \
  "$CONTAINER" \
  jupyter notebook \
    --ip=0.0.0.0 \
    --port=$JUPYTER_PORT \
    --no-browser \
    --NotebookApp.password='' \
    --NotebookApp.token='' \
    --notebook-dir=$CONTAINER_PROJECT_PATH
