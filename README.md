# Borrelia burgdorferi Genome Assembly Pipeline

A complete SLURM-based pipeline for assembling *Borrelia burgdorferi* genomes using Autocycler with Oxford Nanopore long-read sequencing data, from raw POD5 files to polished assembly.

## Overview

This pipeline uses the **Autocycler** multi-assembler consensus approach to generate high-quality bacterial genome assemblies from Oxford Nanopore sequencing data. Starting with raw POD5 files, the workflow includes basecalling, quality control, multi-assembler consensus assembly, and final polishing.

The Autocycler approach runs multiple assemblers (Flye, Canu, NextDenovo) on subsampled read sets, then builds a consensus assembly from the results, providing higher confidence than single-assembler approaches.

## Pipeline Steps

| Script | Step | Description |
|--------|------|-------------|
| `1_dorado.sh` | Basecalling | Convert POD5 files to FASTQ using Dorado GPU basecaller |
| `2_fastqc.sh` | QC | Quality assessment of basecalled reads |
| `3_subsample.sh` | Subsample | Create multiple read subsets for assembly |
| `4_assemble.sh` | Assembly | Run 3 assemblers on 4 subsamples (12 total assemblies) |
| `5_compress_cluster.sh` | Compress | Convert assemblies to unitig graph |
| `6_trim_resolve.sh` | Resolve | Clean and resolve consensus sequences |
| `7_combine.sh` | Combine | Generate final consensus assembly |
| `8_polish_Bb.sh` | Polish | Error-correct with Medaka |

## Requirements

### Software Dependencies
- **Dorado GPU v0.7+** (basecalling)
- **Autocycler v0.6+**
- **Assemblers**: Flye v2.9, Canu v2.2, NextDenovo v2.5
- **Polishing**: Medaka v1.7.2
- **QC**: FastQC, seqkit, NanoStat
- **Utilities**: samtools, seqkit
- **SLURM** job scheduler

### Hardware Requirements
- **GPU**: L40S or similar (required for Dorado basecalling and Medaka polishing)
- **CPU**: 16-32 cores recommended
- **Memory**: 64-128 GB RAM
- **Storage**: ~50 GB for intermediate files (excluding raw POD5 data)

### Input Data
- **POD5 files**: Raw Oxford Nanopore sequencing data
- **Chemistry**: R10.4.1 flowcells with SQK-LSK114 library prep (tested)
- **Expected coverage**: 100x+ for optimal assembly quality

## Usage

1. **Prepare your data:**
   ```bash
   # Organize POD5 files in a directory
   # Update POD5_DIR path in 1_dorado.sh
   # Update output paths in all scripts to match your system
   ```

2. **Run the pipeline:**
   ```bash
   # Submit jobs in sequence (each depends on previous)
   sbatch scripts/1_dorado.sh        # Start with POD5 basecalling
   sbatch scripts/2_fastqc.sh        # After dorado completes
   sbatch scripts/3_subsample.sh     # After fastqc completes
   sbatch scripts/4_assemble.sh      # After subsample completes (array job)
   sbatch scripts/5_compress_cluster.sh
   sbatch scripts/6_trim_resolve.sh
   sbatch scripts/7_combine.sh
   sbatch scripts/8_polish_Bb.sh     # Final polishing step
   ```

3. **Monitor progress:**
   ```bash
   # Check job status
   squeue -u $USER
   
   # Monitor log files
   tail -f logs/dorado_*.out
   tail -f logs/polish_*.out
   ```

4. **Results:**
   - Final assembly: `results/consensus.fasta`
   - Assembly stats: `results/assembly_stats.txt`
   - QC reports: `qc/fastqc_reports/`
   - Complete logs: `logs/`

## Results Summary

**Sample Assembly Metrics:**
- **Total size**: 1,140,821 bp
- **Contigs**: 456
- **Largest contig**: 903,367 bp (79% of genome - likely main chromosome)
- **N50**: 903,367 bp
- **GC content**: 28.27%

The largest contig likely represents the complete *B. burgdorferi* chromosome (~910 kb), with remaining contigs representing the complex plasmid complement typical of this species.

## Key Features

- **Complete workflow**: POD5 → polished assembly
- **GPU-accelerated**: Dorado SUP basecalling for high accuracy
- **Multi-assembler consensus**: More reliable than single assembler
- **Modular SLURM scripts**: Easy to customize and rerun individual steps
- **Error correction**: Medaka polishing for high accuracy
- **Comprehensive QC**: FastQC and assembly statistics
- **Robust logging**: Complete execution history preserved

## Configuration Notes

- **Genome size**: Hardcoded to 1.5 Mb (typical for *B. burgdorferi*)
- **Coverage**: Pipeline designed for high-coverage ONT data (100x+)
- **SLURM partitions**: Adjust `#SBATCH --partition` for your cluster
- **GPU resources**: Uses `guest_gpu` partition with L40S GPUs
- **Dorado model**: Auto-selects SUP model for R10.4.1 chemistry

## Troubleshooting

**Common Issues:**

1. **GPU allocation errors**:
   ```bash
   # Check available GPU resources
   sinfo -p guest_gpu
   ```

2. **NumPy compatibility error (Medaka)**:
   ```bash
   # Add to polishing script:
   PYTHONNOUSERSITE=1 medaka_consensus ...
   ```

3. **Medaka output exists warning**:
   ```bash
   # Clear old output before rerunning:
   rm -rf medaka_out/
   ```

4. **High memory usage**:
   - Monitor jobs with `sstat -j JOBID`
   - Increase `#SBATCH --mem` if needed

5. **Array job failures**:
   ```bash
   # Check individual array task logs
   cat logs/assemble_JOBID_TASKID.err
   ```

## Performance Notes

**Typical Runtime (1.5 Mb genome, 1500x coverage):**
- Dorado basecalling: ~2-4 hours
- FastQC: ~30 minutes
- Subsampling: ~15 minutes
- Assembly: ~4-8 hours per assembler
- Compression/clustering: ~1 hour
- Polishing: ~2-3 hours

**Resource Usage:**
- Peak memory: ~64-128 GB (assembly steps)
- GPU utilization: High during basecalling and polishing
- Storage: ~4 GB raw data → ~50 GB peak → ~10 MB final

## Citation

If you use this pipeline, please cite:

- **Autocycler**: Wick RR, *et al.* (2024) Autocycler: automated multi-assembler pipeline for bacterial genome assembly
- **Dorado**: Oxford Nanopore Technologies (2024) Dorado basecaller
- **Medaka**: Oxford Nanopore Technologies (2024) Medaka consensus tool
- **Flye**: Kolmogorov M, *et al.* (2019) Assembly of long, error-prone reads using repeat graphs. *Nature Biotechnology* 37:540-546
- **Canu**: Koren S, *et al.* (2017) Canu: scalable and accurate long-read assembly via adaptive k-mer weighting and repeat separation. *Genome Research* 27:722-736

## Contributing

Issues and pull requests welcome! This pipeline was developed for *B. burgdorferi* but should work for other bacterial genomes with minor modifications.

## Contact

**Created by**: Zach Pella  
**Affiliation**: APHL-CDC Bioinformatics Fellowship, University of Nebraska Medical Center  
**Lab**: Fauver Lab, Nebraska Public Health Laboratory  
**Purpose**: *Borrelia burgdorferi* genome assembly and tick-borne pathogen surveillance  

## License

MIT License - see LICENSE file for details

---

*Pipeline developed on the Swan HPC cluster at the University of Nebraska-Lincoln for public health genomics applications.*
