# bioinf_project2

## To use pipeline follow this commands:
1. Create and activate necessary environment with conda/mamba (nextflow doesn't work with micromamba, so don't use it):
```bash
mamba create -y -n nf -c bioconda nextflow;
mamba activate nf
```
2. You can launch pipeline from any dir if nextflow.config and pipeline.nf files present there:
```bash
nextflow run pipeline.nf --reads example.fastq --ref example.fasta --output output_dir --coverage_threshold 0 --minvarfreq 0.001
```
