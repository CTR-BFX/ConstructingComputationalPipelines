#!/bin/bash

# --------------------------------------------------------------------------- #
# Russell S. Hamilton, rsh46@cam.ac.uk                                        #
# Centre for Trophoblast Reseach, University of Cambridge                     #
# March 2017                                                                  #
# Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0)    #
# --------------------------------------------------------------------------- #
#                                                                             #
# A very simple bash example of a basic RNA-Seq pipeline                      #
#                                                                             #
# --------------------------------------------------------------------------- #


READ1="RNA-Seq-Project.R1.fq.gz"
READ2="RNA-Seq-Project.R2.fq.gz"

GTF="reference_genome.gtf"
INDEX="reference_genome.hisat2.idx"

# QC metrics on FASTQ files using fastqc
fastqc ${READ1}
fastqc ${READ2}

# Read trimming (adapter & quality) using trim_galore
trim_galore --paired --gzip ${READ1} ${READ2}

# Aligned paired end, trimmed reads to genome/transcriptome using hisat2

BAM=${READ1/.fq.gz/.bam}

hisat2 -x ${INDEX} --no-mixed --no-discordant -1 ${READ1} -2 ${READ2} | samtools view -bS - > ${BAM}

# Generate gene level eads counts using htseq-count

COUNTS=${BAM/.bam/.counts.txt}

htseq-count -t exon -q -f BAM ${BAM} ${GTF} > ${COUNTS}

# Perform some QC on the aligned BAM files using qualimap_rnaseq

QMDIR=${BAM/.bam/.qualimap-rnaseq}
QMFILE=${BAM/.bam/.qualimap-rnaseq.html}

qualimap rnaseq --paired -bam ${BAM} -gtf ${GTF} -outdir ${QMDIR} -outfile ${QMFILE} -outformat HTML

# Produce a summary report using MultiQC

multiqc .

# --------------------------------------------------------------------------- #
# END OF SCRIPT
# --------------------------------------------------------------------------- #
