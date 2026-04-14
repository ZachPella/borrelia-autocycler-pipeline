#!/bin/bash
#SBATCH --job-name=dorado_Bb
#SBATCH --output=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/dorado_%j.out
#SBATCH --error=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/dorado_%j.err
#SBATCH --time=12:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --partition=guest_gpu
#SBATCH --gres=gpu:l40s:4

# ── Paths ──────────────────────────────────────────────────────────────────
POD5_DIR=/work/fauverlab/shared/Bb_WGS_Apr2026/pod5
OUT_DIR=/work/fauverlab/zachpella/Bb_WGS_Apr2026
mkdir -p "$OUT_DIR/logs"

# ── Modules ────────────────────────────────────────────────────────────────
module load dorado-gpu/0.7
module load samtools

# ── Step 1: Basecall POD5 → BAM ────────────────────────────────────────────
# 'sup' lets Dorado auto-select the best sup model for R10.4.1/SQK-LSK114
dorado basecaller sup \
    "$POD5_DIR" \
    --recursive \
    --device cuda:all \
    --no-trim \
    > "$OUT_DIR/Bb_sup.bam"

# ── Step 2: BAM → FASTQ ────────────────────────────────────────────────────
samtools fastq \
    -T '*' \
    "$OUT_DIR/Bb_sup.bam" \
    | gzip > "$OUT_DIR/Bb_sup.fastq.gz"

# ── Step 3: Quick read stats ───────────────────────────────────────────────
module load nanostat 2>/dev/null || true
if command -v NanoStat &>/dev/null; then
    NanoStat --fastq "$OUT_DIR/Bb_sup.fastq.gz" \
             --outdir "$OUT_DIR/nanostat" \
             --threads 16
fi

echo "Done. Reads: $OUT_DIR/Bb_sup.fastq.gz"
