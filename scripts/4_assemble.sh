#!/bin/bash
#SBATCH --job-name=assemble_Bb
#SBATCH --output=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/assemble_%A_%a.out
#SBATCH --error=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/assemble_%A_%a.err
#SBATCH --time=24:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=64G
#SBATCH --partition=guest
#SBATCH --array=1-3

set -euo pipefail

# ── Paths ──────────────────────────────────────────────────────────────────
WORKDIR=/work/fauverlab/zachpella/Bb_WGS_Apr2026
SUBSAMPLE_DIR=$WORKDIR/subsampled_reads
ASSEMBLY_DIR=$WORKDIR/assemblies
mkdir -p "$ASSEMBLY_DIR"

# ── Modules ────────────────────────────────────────────────────────────────
module load autocycler/0.6

# ── Assembler selection via array task ID ──────────────────────────────────
ASSEMBLERS=(flye canu nextdenovo)
ASSEMBLER=${ASSEMBLERS[$SLURM_ARRAY_TASK_ID - 1]}

echo "Array task $SLURM_ARRAY_TASK_ID: running $ASSEMBLER"

# ── Load assembler-specific module ────────────────────────────────────────
case $ASSEMBLER in
    flye)       module load flye/2.9 ;;
    canu)       module load canu/2.2 ;;
    nextdenovo) module load nextdenovo/2.5
                module load nextpolish/1.4
		module load minimap2 ;;
esac

# ── Run assembler on all 4 subsamples ─────────────────────────────────────
for i in 01 02 03 04; do
    echo "  Running $ASSEMBLER on sample_$i..."
    autocycler helper "$ASSEMBLER" \
        --reads "$SUBSAMPLE_DIR/sample_$i.fastq" \
        --out_prefix "$ASSEMBLY_DIR/${ASSEMBLER}_$i" \
        --threads 16 \
        --genome_size 1500000 \
        --read_type ont_r10 \
        --min_depth_rel 0.1
done

echo "Done: $ASSEMBLER assemblies complete"
ls -lh "$ASSEMBLY_DIR/${ASSEMBLER}"*.fasta 2>/dev/null || echo "Warning: no FASTA output found for $ASSEMBLER"
