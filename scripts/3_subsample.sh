#!/bin/bash
#SBATCH --job-name=subsample_Bb
#SBATCH --output=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/subsample_%j.out
#SBATCH --error=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/subsample_%j.err
#SBATCH --time=01:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=guest

set -euo pipefail

# ── Paths ──────────────────────────────────────────────────────────────────
WORKDIR=/work/fauverlab/zachpella/Bb_WGS_Apr2026
READS=$WORKDIR/Bb_sup.fastq.gz
SUBSAMPLE_DIR=$WORKDIR/subsampled_reads

mkdir -p "$SUBSAMPLE_DIR"

# ── Modules ────────────────────────────────────────────────────────────────
module load autocycler

# ── Subsample ──────────────────────────────────────────────────────────────
# Genome size hardcoded at 1.5 Mb — raven estimation fails at extreme coverage
autocycler subsample \
    --reads "$READS" \
    --out_dir "$SUBSAMPLE_DIR" \
    --genome_size 1500000 \

echo "Done. Subsampled reads in: $SUBSAMPLE_DIR"
ls -lh "$SUBSAMPLE_DIR"
