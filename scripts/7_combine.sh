#!/bin/bash
#SBATCH --job-name=combine_Bb
#SBATCH --output=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/combine_%j.out
#SBATCH --error=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/combine_%j.err
#SBATCH --time=1:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=16G
#SBATCH --partition=guest

set -euo pipefail

# ── Paths ──────────────────────────────────────────────────────────────────
WORKDIR=/work/fauverlab/zachpella/Bb_WGS_Apr2026
AUTOCYCLER_OUT=$WORKDIR/autocycler_out
QC_PASS=$AUTOCYCLER_OUT/clustering/qc_pass

# ── Modules ────────────────────────────────────────────────────────────────
module load autocycler/0.6

# ── Sanity check ──────────────────────────────────────────────────────────
N_FINAL=$(ls "$QC_PASS"/cluster_*/5_final.gfa 2>/dev/null | wc -l)
if [ "$N_FINAL" -eq 0 ]; then
    echo "ERROR: no 5_final.gfa files found. Did 6_trim_resolve.sh complete?"
    exit 1
fi
echo "Combining $N_FINAL resolved cluster(s)..."

# ── Step 7: Combine into final consensus assembly ─────────────────────────
autocycler combine \
    -a "$AUTOCYCLER_OUT" \
    -i "$QC_PASS"/cluster_*/5_final.gfa

echo "Done!"
echo "Final assembly: $AUTOCYCLER_OUT/consensus_assembly.fasta"
ls -lh "$AUTOCYCLER_OUT/consensus_assembly.fasta"

# ── Quick summary ─────────────────────────────────────────────────────────
module load seqkit 2>/dev/null || true
if command -v seqkit &>/dev/null; then
    echo ""
    echo "Assembly stats:"
    seqkit stats -a "$AUTOCYCLER_OUT/consensus_assembly.fasta"
fi
