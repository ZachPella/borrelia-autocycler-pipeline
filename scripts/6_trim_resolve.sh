#!/bin/bash
#SBATCH --job-name=trim_resolve_Bb
#SBATCH --output=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/trim_resolve_%j.out
#SBATCH --error=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/trim_resolve_%j.err
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=8
#SBATCH --mem=32G
#SBATCH --partition=guest

set -euo pipefail

# ── Paths ──────────────────────────────────────────────────────────────────
WORKDIR=/work/fauverlab/zachpella/Bb_WGS_Apr2026
AUTOCYCLER_OUT=$WORKDIR/autocycler_out
QC_PASS=$AUTOCYCLER_OUT/clustering/qc_pass

# ── Modules ────────────────────────────────────────────────────────────────
module load autocycler/0.6

# ── Sanity check ──────────────────────────────────────────────────────────
if [ ! -d "$QC_PASS" ]; then
    echo "ERROR: $QC_PASS not found. Did 5_compress_cluster.sh finish successfully?"
    exit 1
fi

N_CLUSTERS=$(ls -d "$QC_PASS"/cluster_* 2>/dev/null | wc -l)
echo "Found $N_CLUSTERS QC-pass cluster(s)"

# ── Steps 5 & 6: Trim and resolve each cluster ────────────────────────────
for c in "$QC_PASS"/cluster_*; do
    echo "Processing cluster: $(basename $c)"

    echo "  Trimming..."
    autocycler trim -c "$c"

    # Optional: dotplot for plasmid-sized clusters (<1 Mb GFA)
    if [[ $(wc -c < "$c/1_untrimmed.gfa") -lt 1000000 ]]; then
        echo "  Generating dotplots..."
        autocycler dotplot -i "$c/1_untrimmed.gfa" -o "$c/1_untrimmed.png" 2>/dev/null || true
        autocycler dotplot -i "$c/2_trimmed.gfa"   -o "$c/2_trimmed.png"   2>/dev/null || true
    fi

    echo "  Resolving..."
    autocycler resolve -c "$c"

    echo "  Done: $(basename $c)"
done

echo "All clusters trimmed and resolved."
ls "$QC_PASS"/cluster_*/5_final.gfa 2>/dev/null || echo "Warning: no 5_final.gfa files found"
