# Transcriptomics workflow learning project

This project is for my portfolio to demonstrate building reproducible transcriptomics workflows with Snakemake and Nextflow. The goal is for both workflows to use the same inputs and produce comparable outputs.

**Status:** Snakemake development is in progress; the Nextflow workflow is in progress.

## Structure

```text
transcriptomics-starter/
├── config/                 # Shared settings
├── data/                   # Sample metadata; downloaded reads stay out of Git
├── results/                # Generated outputs (ignored by Git)
├── scripts/                # Shared R/Python analysis and report scripts
├── workflows/
│   ├── nextflow/           # Nextflow workflow
│   └── snakemake/          # Snakemake workflow
├── .gitignore
└── README.md
```

The development of these pipelines was ran remotely in WSL2 for a Linux-compatible bioinformatics environment.

## Shared test dataset

Download the paired-end, subsampled *S. cerevisiae* test sample once from the
project root in WSL:

```bash
bash scripts/download_nfcore_test_data.sh
```

This writes the reads and a local-path samplesheet to `data/nf-core-test/`.
The source revision is pinned in the script for reproducibility. The FASTQ
files are test inputs, not biological evidence, and are excluded from Git.

## Current Snakemake workflow

From the project root, run:

```bash
snakemake \
  --snakefile workflows/snakemake/Snakefile \
  --configfile workflows/snakemake/config/config.yaml \
  --use-conda \
  --cores 1
```

The starter data is for workflow testing, not biological analysis.
