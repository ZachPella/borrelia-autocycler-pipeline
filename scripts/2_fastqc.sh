#!/bin/bash
#SBATCH --job-name=fastqc_Bb
#SBATCH --output=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/fastqc_%j.out
#SBATCH --error=/work/fauverlab/zachpella/Bb_WGS_Apr2026/logs/fastqc_%j.err
#SBATCH --time=02:00:00
#SBATCH --cpus-per-task=4
#SBATCH --mem=65G
#SBATCH --partition=guest

# ── Paths ──────────────────────────────────────────────────────────────────
BASEDIR="/work/fauverlab/zachpella/Bb_WGS_Apr2026"
FASTQ="${BASEDIR}/Bb_sup.fastq.gz"
QCDIR="${BASEDIR}/fastqc_reports"

mkdir -p "${QCDIR}"

# ── Check input ────────────────────────────────────────────────────────────
if [[ ! -f "${FASTQ}" ]]; then
    echo "✗ ERROR: FASTQ not found: ${FASTQ}"
    exit 1
fi

echo "Running FastQC on $(basename ${FASTQ})..."
echo "Started at: $(date)"

# ── Modules ────────────────────────────────────────────────────────────────
module purge
module load fastqc/0.12

# ── Run FastQC ─────────────────────────────────────────────────────────────
fastqc --threads 4 --memory 10000 --outdir="${QCDIR}" "${FASTQ}"

# ── Verify output ──────────────────────────────────────────────────────────
HTML="${QCDIR}/Bb_sup_fastqc.html"
if [[ -f "${HTML}" ]]; then
    echo "✓ FastQC completed successfully"
else
    echo "✗ Error: FastQC output not created"
    exit 1
fi

echo "Completed at: $(date)"
