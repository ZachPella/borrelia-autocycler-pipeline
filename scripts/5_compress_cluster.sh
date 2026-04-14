#!/bin/bash
#SBATCH --job-name=compress_cluster_Bb
#SBATCH --output=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/compress_cluster_%j.out
#SBATCH --error=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/compress_cluster_%j.err
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=guest

set -euo pipefail

# ── Paths ──────────────────────────────────────────────────────────────────
WORKDIR=/work/fauverlab/zachpella/Bb_WGS_Apr2026
ASSEMBLY_DIR=$WORKDIR/assemblies
AUTOCYCLER_OUT=$WORKDIR/autocycler_out

# ── Modules ────────────────────────────────────────────────────────────────
module load autocycler/0.6

# ── Step 3: Compress assemblies into unitig graph ──────────────────────────
echo "Running autocycler compress..."
autocycler compress \
    -i "$ASSEMBLY_DIR" \
    -a "$AUTOCYCLER_OUT"

# ── Step 4: Cluster contigs into putative genomic sequences ────────────────
echo "Running autocycler cluster..."
autocycler cluster \
    -a "$AUTOCYCLER_OUT"

echo "Done. Check QC-pass clusters:"
ls "$AUTOCYCLER_OUT/clustering/qc_pass/" 2>/dev/null || echo "Warning: no qc_pass clusters found"
