
# Constructing Computational Pipelines


Russell S. Hamilton


Examples in different pipeline formats for a very basic 5 step RNA-Seq workflow. This is intended to describe different pipeline approaches, not to perform a genuine RNA-Seq analysis.

The 5 basic steps are:
* QC of the FASTQ files using `fastqc`
* Adapter and quality trimming using `trim_galore`
* Alignment to a genome/transcriptome using `hisat2`
* QC matrics on the aligned BAM files using `qualimap`
* Summary report using `multiqc`

## Bash Script Examples of Simple RNA-Seq

    SimpleRNA-Seq.sh

## Clusterflow Example of Simple RNA-Seq


## eHive Example of Simple RNA-Seq

* Pipeline configuration file
   ehiveRNAseq/RNAseq_conf.pm
