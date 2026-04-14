# Borrelia burgdorferi Genome Assembly Pipeline

A complete SLURM-based pipeline for assembling *Borrelia burgdorferi* genomes using Autocycler with Oxford Nanopore long-read sequencing data.

## Overview

This pipeline uses the **Autocycler** multi-assembler consensus approach to generate high-quality bacterial genome assemblies from Oxford Nanopore sequencing data. Autocycler runs multiple assemblers (Flye, Canu, NextDenovo) on subsampled read sets, then builds a consensus assembly from the results.

## Pipeline Steps

| Script | Step | Description |
|--------|------|-------------|
| `2_fastqc.sh` | QC | Quality assessment of raw reads |
| `3_subsample.sh` | Subsample | Create multiple read subsets for assembly |
| `4_assemble.sh` | Assembly | Run 3 assemblers on 4 subsamples (12 total assemblies) |
| `5_compress_cluster.sh` | Compress | Convert assemblies to unitig graph |
| `6_trim_resolve.sh` | Resolve | Clean and resolve consensus sequences |
| `7_combine.sh` | Combine | Generate final consensus assembly |
| `8_polish_Bb.sh` | Polish | Error-correct with Medaka |

## Requirements

### Software Dependencies
- **Autocycler v0.6+**
- **Assemblers**: Flye v2.9, Canu v2.2, NextDenovo v2.5
- **Polishing**: Medaka v1.7.2
- **QC**: FastQC, seqkit, NanoStat
- **SLURM** job scheduler

### Hardware Requirements
- **CPU**: 16-32 cores recommended
- **Memory**: 64-128 GB RAM
- **Storage**: ~50 GB for intermediate files
- **GPU**: Required for Medaka polishing

## Usage

1. **Prepare your data:**
   ```bash
   # Place your ONT reads as: Bb_sup.fastq.gz
   # Update paths in scripts to match your system
   ```

2. **Run the pipeline:**
   ```bash
   # Submit jobs in sequence (each depends on previous)
   sbatch scripts/2_fastqc.sh
   sbatch scripts/3_subsample.sh      # After fastqc completes
   sbatch scripts/4_assemble.sh       # After subsample completes
   sbatch scripts/5_compress_cluster.sh
   sbatch scripts/6_trim_resolve.sh
   sbatch scripts/7_combine.sh
   sbatch scripts/8_polish_Bb.sh
   ```

3. **Results:**
   - Final assembly: `results/consensus.fasta`
   - Assembly stats: `results/assembly_stats.txt`
   - QC reports: `qc/fastqc_reports/`

## Results Summary

**Sample Assembly Metrics:**
- **Total size**: 1,140,821 bp
- **Contigs**: 456
- **Largest contig**: 903,367 bp (79% of genome - likely main chromosome)
- **N50**: 903,367 bp
- **GC content**: 28.27%

The largest contig likely represents the complete *B. burgdorferi* chromosome (~910 kb), with remaining contigs representing the complex plasmid complement typical of this species.

## Key Features

- **Multi-assembler consensus**: More reliable than single assembler
- **Modular SLURM scripts**: Easy to customize and rerun individual steps
- **Error correction**: Medaka polishing for high accuracy
- **Comprehensive QC**: FastQC and assembly statistics

## Configuration Notes

- **Genome size**: Hardcoded to 1.5 Mb (typical for *B. burgdorferi*)
- **Coverage**: Pipeline designed for high-coverage ONT data (100x+)
- **SLURM partitions**: Adjust `#SBATCH --partition` for your cluster

## Troubleshooting

**Common Issues:**

1. **NumPy compatibility error (Medaka)**:
   ```bash
   # Add to polishing script:
   PYTHONNOUSERSITE=1 medaka_consensus ...
   ```

2. **Medaka output exists warning**:
   ```bash
   # Clear old output before rerunning:
   rm -rf medaka_out/
   ```

## Citation

If you use this pipeline, please cite:

- **Autocycler**: Wick RR, *et al.* (2024) Autocycler: automated multi-assembler pipeline for bacterial genome assembly
- **Medaka**: Oxford Nanopore Technologies (2024) Medaka consensus tool
- **Flye**: Kolmogorov M, *et al.* (2019) Assembly of long, error-prone reads using repeat graphs. *Nature Biotechnology* 37:540-546

## Contact

Created by: Zach Pella  
Affiliation: APHL-CDC Bioinformatics Fellowship, University of Nebraska Medical Center  
Pipeline developed for: *Borrelia burgdorferi* genome assembly and tick-borne pathogen surveillance

## License

MIT License - see LICENSE file for details
