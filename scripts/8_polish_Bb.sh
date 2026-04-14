#!/bin/bash
#SBATCH --job-name=polish_Bb
#SBATCH --output=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/polish_%j.out
#SBATCH --error=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/polish_%j.err
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --partition=guest_gpu
#SBATCH --gres=gpu:l40s:1

set -euo pipefail

# ── Paths ──────────────────────────────────────────────────────────────────
WORKDIR=/work/fauverlab/zachpella/Bb_WGS_Apr2026
DRAFT=$WORKDIR/autocycler_out/consensus_assembly.fasta
READS=$WORKDIR/Bb_sup.fastq.gz
OUTDIR=$WORKDIR/medaka_out
mkdir -p "$OUTDIR"

# ── Modules ────────────────────────────────────────────────────────────────
module load medaka-gpu/py38/1.7

# ── Model ─────────────────────────────────────────────────────────────────
# R10.4.1 flow cell, 400 bps, SUP basecalling
MODEL=r1041_e82_400bps_sup_g615

# ── Polish ─────────────────────────────────────────────────────────────────
PYTHONNOUSERSITE=1 medaka_consensus \
    -i "$READS" \
    -d "$DRAFT" \
    -o "$OUTDIR" \
    -m "$MODEL" \
    -t 16

echo "Done: $(date)"
echo "Polished assembly: $OUTDIR/consensus.fasta"
ls -lh "$OUTDIR/consensus.fasta"

# ── Quick stats ────────────────────────────────────────────────────────────
module load seqkit 2>/dev/null || true
if command -v seqkit &>/dev/null; then
    echo ""
    echo "Polished assembly stats:"
    seqkit stats -a "$OUTDIR/consensus.fasta"
fi
